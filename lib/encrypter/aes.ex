defmodule Encrypter.AES do
  def encrypt_file_aes_256(path, folder_key, initialisation_vector) do
    {:ok, folder_key} = Base.decode16(folder_key)
    {:ok, plain_text} = File.read(path)

    cipher_text = :crypto.block_encrypt(:aes_cbc256,
                                        folder_key,
                                        initialisation_vector,
                                        pkcs5_pad(plain_text))
    # Overwrite the uploaded temp file with the encrypted temp file
    File.write(path, cipher_text)
  end

  # Padding function according to PKCS#5
  # If it's evenly divisible by 16 add 16 16s
  # Otherwise add 16 - remainder, 16 - remainder times
  defp pkcs5_pad(plain_text) do
    padding = 16 - rem(byte_size(plain_text), 16)
    plain_text <> String.duplicate(<<padding>>, padding)
  end
end
