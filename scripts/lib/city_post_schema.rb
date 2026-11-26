# frozen_string_literal: true

module CityPostSchema
  REQUIRED_FIELDS = %w[
    aplikasi_kayu_dolken area_pengiriman area_pengiriman_detail author author_url
    comment_count date description excerpt faq_pemesanan faq_pengiriman faq_produk
    finalisasi_pengiriman image image_alt images images_alt keunggulan_durabilitas
    keunggulan_kayu_dolken keunggulan_layanan keunggulan_nilai keunggulan_produk
    keywords last_modified_at layout like_count nama_kota proses_awal_pemesanan
    rating relevansi_kayu_dolken review_count share_count show_products
    studi_kasus_proyek tentang_kota testimoni_komersial testimoni_residential
    tips_ukuran title
  ].freeze

  PLACEHOLDER_PATTERN = /\{\{[^}]+\}\}|\{NAMA_KOTA\}|\{kota\}|\{KOTA\}/.freeze

  def self.missing_fields(fields)
    present = fields.keys.map(&:to_s)
    REQUIRED_FIELDS.reject { |field| present.include?(field) }
  end

  def self.placeholders(fields)
    fields.filter_map do |name, value|
      name.to_s if placeholder?(value)
    end
  end

  def self.placeholder?(value)
    case value
    when String
      PLACEHOLDER_PATTERN.match?(value)
    when Hash
      value.values.any? { |nested| placeholder?(nested) }
    when Array
      value.any? { |nested| placeholder?(nested) }
    else
      false
    end
  end

  private_class_method :placeholder?
end
