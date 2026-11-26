# frozen_string_literal: true

# Migrasi sekali pakai: mengisi date/last_modified_at artikel kota dengan
# timestamp UTC unik sampai detik. Alokasi dari hash slug; tidak memakai git.
require_relative "lib/post_timestamps"

root = Dir.pwd
PostTimestamps.articles(root).each do |path|
  name = File.basename(path)
  slug = name[/\A\d{4}-\d{2}-\d{2}-jual-kayu-dolken-(.*)\.md\z/, 1]
  tanggal = name[/\A(\d{4}-\d{2}-\d{2})-/, 1]
  abort "nama artikel tidak dikenali: #{name}" unless slug && tanggal

  date, modified = PostTimestamps.allocate(root: root, slug: slug, tanggal: tanggal)
  PostTimestamps.rewrite_article(path: path, date: date, modified: modified)
  puts "#{name}: #{date} | #{modified}"
end
