# coding: utf-8
class Matrix < ActiveRecord::Base
  validate :data_validate
  validates_numericality_of :size, :only_integer => true, :greater_than => 0, :less_than => 100

  attr_accessor :data, :b, :x
  attr_reader :algorithm, :timer

  EPS = 1e-6

  def initialize(attributes = {})
    attributes ||= {}
    data = attributes.delete('data')
    b = attributes.delete('b')
    super(attributes)
    self.size ||= 2
    if data
      @data = Matrix.hash_with_integer_keys(data).sort.map(&:last).map(&:sort).inject([]) { |memo, row| memo << row.map(&:last) } #wow! from hash to matrix
    else
      @data = Array.new([size, 0].max, Array.new([size, 0].max, 0))
    end
    if b
      @b = Matrix.hash_with_integer_keys(b).sort.map(&:last)
    else
      @b = Array.new([0, size].max, 0)
    end
  end

  #{'0'=>2, '1'=>3} => {0 => 2, 1 => 3}
  def self.hash_with_integer_keys(hash)
    hash.inject({}) do |memo, (key, value)|
      value = hash_with_integer_keys(value) if value.class == HashWithIndifferentAccess or value.class == Hash
      memo[key.to_i] = value
      memo
    end
  end

  def data_validate
    @data.each do |row|
      row.each_with_index do |cell, i|
        begin
          row[i] = Float(cell)
        rescue ArgumentError
          errors.add_to_base "#{cell} не является корректным числом Float."
        end
      end
    end
    @b.each_with_index do |cell, i|
      begin
        @b[i] = Float(cell)
      rescue ArgumentError
        errors.add_to_base "#{cell} не является корректным числом Float."
      end
    end
  end

  def solve
    if tridiagonal?
      solve_tdma
    else
      solve_gauss
    end
  end

  def solve_gauss
    @algorithm = "метод Гаусса"
    @timer = Time.now
    0.upto(size-2) do |i|
      swap_lines(i, find_max_elem(i))
      (i+1).upto(size-1) { |j| zero_line(i, j) }
    end
    (size-1).downto 1 do |i|
      (i-1).downto(0) { |j| zero_line(i, j) }
    end
    @x = @data.inject_with_index([]) do |memo, row, i|
      memo << b[i] / row[i]
    end
  rescue ArgumentError => e
    errors.add_to_base e.message
  ensure
    @timer = Time.now - @timer
    logger.info "size = #{size}; solve_gauss: @timer = #{@timer}"
  end

  def tridiagonal?
    @data.each_with_index do |row, i|
      if ((row[0, i - 1] || []) + (row[i+2, row.length] || [])).detect { |c| not zero?(c) }
        return false
      end
      return false if zero?(row[i])
    end
    true
  end

  #Solve tridiagonal matrix. Doesn't care about tridiagonal matrix format. Use +tridiagonal?+ to check.
  def solve_tdma
    @algorithm = "метод прогонки"
    0.upto (size-2) do |i|
      k = -@data[i+1][i] / @data[i][i]
      for j in i..[i+2, size-1].min
        @data[i+1][j] += k*@data[i][j]
      end
      b[i+1] += k*b[i]
    end
    (size-1).downto 1 do |i|
      k = -@data[i-1][i] / @data[i][i]
      @data[i-1][i] += k*@data[i][i]
      b[i-1] += k*b[i]
    end
    @x = @data.inject_with_index([]) do |memo, row, i|
      memo << b[i] / row[i]
    end
  end

  #Returns index of row with maximum element in column_index position, starting from column_index row
  def find_max_elem(column_index)
    max_index = column_index
    @data[column_index, @data.length].each_with_index do |row, index|
      max_index = index + column_index if row[column_index].abs > @data[max_index][column_index].abs
    end
    max_index
  end

  def swap_lines(i, j)
    @data[i], @data[j] = @data[j], @data[i]
    @b[i], @b[j] = @b[j], @b[i]
  end

  def add_line(source, k, destination)
    @data[source].each_with_index do |elem, i|
      @data[destination][i] += elem*k
    end
    b[destination] += b[source] * k
  end

  def zero_line(source, dest)
    raise ArgumentError, "СЛАУ имеет бесконечноe число решений" if zero?(@data[source][source])
    k = -@data[dest][source] / @data[source][source]
    add_line(source, k, dest)
  end

  def zero?(value)
    value.abs < EPS
  end

  MAX_DATA_NUM = 100
  #create random matrix with current size
  def randomize
    @data = @data.map do |row|
      row.map do |cell|
          rand(MAX_DATA_NUM).to_f
      end
    end
    @b = @b.map do |cell|
      rand(MAX_DATA_NUM).to_f
    end
    logger.info "RANDOMIZED @data:"
    logger.info @data.inspect
    logger.info "RANDOMIZED @b:"    
    logger.info @b.inspect
    self
  end
end
