class Matrix < ActiveRecord::Base
  validate :data_validate
  validates_numericality_of :size, :only_integer => true, :greater_than => 0

  attr_accessor :data, :b, :x

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

  def solve_gauss
    0.upto (size-2) do |i|
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
end
