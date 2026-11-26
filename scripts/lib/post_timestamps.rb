# frozen_string_literal: true

require "date"
require "digest"
require "time"
require "yaml"

# Aturan timestamp frontmatter artikel kota: UTC dengan detik, unik per artikel,
# tanggal kalender mengikuti nama file supaya permalink tidak berubah.
module PostTimestamps
  class Error < StandardError; end

  FIELDS = %w[date last_modified_at].freeze
  FORMAT = "%Y-%m-%d %H:%M:%S +0000".freeze
  PARSE_FORMAT = "%Y-%m-%d %H:%M:%S %z".freeze
  PATTERN = /\A\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \+0000\z/.freeze
  FRONTMATTER_PATTERN = /\A---[ \t]*\r?\n(.*?)^---[ \t]*\r?$/m.freeze
  FILENAME_DATE_PATTERN = /\A(\d{4}-\d{2}-\d{2})-/.freeze

  # 08:00-12:30 WIB = 01:00-05:30 UTC pada tanggal yang sama.
  PUBLISH_OFFSET = 1 * 3600
  PUBLISH_SPAN = 4 * 3600 + 30 * 60
  # Disunting 1-3 jam setelah terbit; untuk artikel hari ini maksimal 15:30 WIB.
  MODIFIED_MIN_DELAY = 1 * 3600
  MODIFIED_DELAY_SPAN = 2 * 3600

  Result = Struct.new(:errors, keyword_init: true) do
    def success?
      errors.empty?
    end
  end

  module_function

  def format(time)
    time.utc.strftime(FORMAT)
  end

  def parse(value)
    return nil unless value.is_a?(String) && PATTERN.match?(value)

    Time.strptime(value, PARSE_FORMAT).utc
  rescue ArgumentError
    nil
  end

  # Hanya untuk membaca nilai lama saat migrasi; bukan untuk menulis.
  def legacy_time(value)
    text = value.to_s.strip.sub(/\A['"]/, "").sub(/['"]\z/, "")
    if text.match?(/\A\d{4}-\d{2}-\d{2}\z/)
      Time.strptime("#{text} 00:00:00 +0000", PARSE_FORMAT).utc
    else
      Time.parse(text).utc
    end
  rescue ArgumentError
    nil
  end

  def articles(root)
    Dir[File.join(root, "_post_with_city", "*.md")].sort
  end

  def frontmatter(path)
    text = File.read(path)
    raw = text[FRONTMATTER_PATTERN, 1] || ""
    YAML.safe_load(raw, permitted_classes: [Date, Time], aliases: true) || {}
  end

  def used_values(root)
    used = Hash[FIELDS.map { |field| [field, []] }]
    articles(root).each do |path|
      data = frontmatter(path)
      FIELDS.each do |field|
        time = legacy_time(data[field]) if data[field]
        used[field] << format(time) if time
      end
    end
    used
  end

  def next_unique(base, used)
    candidate = base
    loop do
      formatted = format(candidate)
      return formatted unless used.include?(formatted)

      candidate += 1
    end
  end

  def natural_times(slug:, tanggal:)
    day = Time.strptime("#{tanggal} 00:00:00 +0000", PARSE_FORMAT).utc
    publish_slot = Digest::SHA256.hexdigest("pub:#{slug}").to_i(16) % PUBLISH_SPAN
    delay = MODIFIED_MIN_DELAY +
            (Digest::SHA256.hexdigest("mod:#{slug}").to_i(16) % MODIFIED_DELAY_SPAN)

    publish = day + PUBLISH_OFFSET + publish_slot
    [publish, publish + delay]
  end

  def allocate(root:, slug:, tanggal:)
    used = used_values(root)
    publish, delay_until = natural_times(slug: slug, tanggal: tanggal)
    date = next_unique(publish, used["date"])
    modified = next_unique(delay_until, used["last_modified_at"])
    [date, modified]
  end

  def validate(root: Dir.pwd)
    errors = []
    seen = Hash[FIELDS.map { |field| [field, {}] }]

    articles(root).each do |path|
      name = File.basename(path)
      filename_date = name[FILENAME_DATE_PATTERN, 1]
      data = frontmatter(path)
      values = {}

      FIELDS.each do |field|
        if data[field].nil?
          errors << "field wajib hilang: #{field} (#{name})"
          next
        end

        unless PATTERN.match?(data[field].to_s)
          errors << "format timestamp tidak valid: #{field}=#{data[field].inspect} (#{name})"
          next
        end

        time = parse(data[field])
        unless time
          errors << "tanggal tidak sah: #{field}=#{data[field].inspect} (#{name})"
          next
        end

        values[field] = time
        formatted = format(time)
        if seen[field][formatted]
          errors << "duplikat #{field}: #{formatted} (#{seen[field][formatted]} dan #{name})"
        else
          seen[field][formatted] = name
        end
      end

      next unless values["date"] && values["last_modified_at"]

      if values["last_modified_at"] < values["date"]
        errors << "last_modified_at lebih awal dari date: #{name}"
      end
      if filename_date && values["date"].strftime("%Y-%m-%d") != filename_date
        errors << "tanggal date tidak cocok dengan nama file: #{name}"
      end
    end

    Result.new(errors: errors)
  end

  def rewrite_article(path:, date:, modified:)
    text = File.read(path)
    FIELDS.each do |field|
      unless text.match?(/^#{field}:[^\r\n]*$/)
        raise Error, "field #{field} tidak ditemukan: #{path}"
      end
    end

    updated = text.sub(/^date:[^\r\n]*$/, "date: '#{date}'")
                  .sub(/^last_modified_at:[^\r\n]*$/, "last_modified_at: '#{modified}'")
    File.write(path, updated)
    path
  end
end
