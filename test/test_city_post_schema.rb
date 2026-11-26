# frozen_string_literal: true

require "minitest/autorun"
require_relative "../scripts/lib/city_post_schema"

class CityPostSchemaTest < Minitest::Test
  CANONICAL_FIELDS = %w[
    aplikasi_kayu_dolken area_pengiriman area_pengiriman_detail author author_url
    comment_count date description excerpt faq_pemesanan faq_pengiriman faq_produk
    finalisasi_pengiriman image image_alt images images_alt keunggulan_durabilitas
    keunggulan_kayu_dolken keunggulan_layanan keunggulan_nilai keunggulan_produk
    keywords last_modified_at layout like_count nama_kota proses_awal_pemesanan
    rating relevansi_kayu_dolken review_count share_count show_products
    studi_kasus_proyek tentang_kota testimoni_komersial testimoni_residential
    tips_ukuran title
  ].freeze

  def test_required_fields_matches_canonical_list
    assert_equal CANONICAL_FIELDS.sort, CityPostSchema::REQUIRED_FIELDS.sort
  end

  def test_missing_fields_with_empty_hash
    assert_equal CANONICAL_FIELDS.sort, CityPostSchema.missing_fields({}).sort
  end

  def test_missing_fields_ignores_present_fields
    missing = CityPostSchema.missing_fields("nama_kota" => "Bogor", "title" => "x")
    assert_equal((CANONICAL_FIELDS - %w[nama_kota title]).sort, missing.sort)
  end

  def test_placeholders_detects_template_tokens
    fields = { "title" => "Jual {{nama_kota}}", "description" => "{NAMA_KOTA}" }
    assert_equal %w[title description], CityPostSchema.placeholders(fields)
  end

  def test_placeholders_ignores_real_text
    assert_empty CityPostSchema.placeholders("title" => "Jual Kayu Dolken Bogor")
  end
end
