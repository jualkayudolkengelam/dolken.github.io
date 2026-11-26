# frozen_string_literal: true

# Foto baru diletakkan di source-image/. Setelah dipakai, foto dipindah ke
# source-image/sudah-terpakai/ agar tidak terpilih lagi untuk artikel berikutnya.
# Provenance lama tetap menunjuk ke path asalnya; resolver ini mencarinya di
# arsip bila file sudah tidak ada di root.
module SourceImage
  ARCHIVE_DIR = "sudah-terpakai"

  module_function

  def archived?(relative)
    relative.to_s.split(File::SEPARATOR).first == ARCHIVE_DIR
  end

  def path(root, relative)
    relative = relative.to_s.sub(%r{\A/}, "")
    return nil if relative.empty? || archived?(relative)

    base = File.expand_path(File.join(root, "source-image"))
    [relative, File.join(ARCHIVE_DIR, relative)].each do |candidate|
      absolute = File.expand_path(File.join(base, candidate))
      next unless absolute.start_with?(base + File::SEPARATOR)

      return absolute if File.file?(absolute)
    end
    nil
  end
end
