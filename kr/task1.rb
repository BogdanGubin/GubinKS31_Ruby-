class FileBatchEnumerator
  def initialize(file_path, batch_size)
    @file_path = file_path
    @batch_size = batch_size
  end

  def each
    return enum_for(:each) unless block_given?

    File.open(@file_path, "r") do |file|
      batch = []
      file.each_line do |line|
        batch << line.chomp
        if batch.size == @batch_size
          yield batch
          batch = []
        end
      end
      yield batch unless batch.empty?  
    end
  end
end


enumerator = FileBatchEnumerator.new("file.txt", 5)
enumerator.each do |batch|
  puts "Батч рядків"
  p batch
end
