defmodule Encrypter.AES do
  def encrypt_file_aes_256(path, folder_key, initialisation_vector) do
    {:ok, folder_key} = Base.decode16(folder_key)
    {:ok, plain_text} = File.read(path)

    # Encrypt the temp file with aes-cbc-256
    cipher_text = :crypto.block_encrypt(:aes_cbc256,
                                        folder_key,
                                        initialisation_vector,
                                        pkcs5_pad(plain_text, 16))
    # Overwrite the uploaded temp file with the encrypted temp file
    File.write(path, cipher_text)
  end

  # Padding function according to PKCS#5
  # Add (block_size - remainder), (block_size - remainder) times
  defp pkcs5_pad(plain_text, block_size) do
    padding = block_size - rem(byte_size(plain_text), block_size)
    plain_text <> String.duplicate(<<padding>>, padding)
  end
end
