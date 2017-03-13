RSpec::Matchers.define :express do |expected|
  match do |actual|
    actual.to_s == expected.gsub(/\n\s*/, ' ').strip
  end

  failure_message do |actual|
    %(expected expression to express "#{expected}" but actually it expresses "#{actual}")
  end
end

describe Gmail::Filters::Expr do
  def const(name)
    Gmail::Filters::Expr.const_get(name)
  end

  def expr(type, *args)
    const(type).new(*args)
  end

  describe 'build' do
    let :strs { %w(from:foo from:bar to:foo to:bar) }
    subject { described_class.build(strs) }
    it { should express %((from:foo OR from:bar) AND (to:foo OR to:bar)) }
  end

  describe 'a OR b OR c'  do
    subject { expr(:Or, 'a', 'b', 'c') }
    it { should express 'a OR b OR c' }
  end

  describe 'a AND b AND c'  do
    subject { expr(:And, 'a', 'b', 'c') }
    it { should express 'a AND b AND c' }
  end

  describe '(a OR b) AND (c OR d)' do
    subject { expr(:And, expr(:Or, 'a', 'b'), expr(:Or, 'c', 'd')) }
    it { should express '(a OR b) AND (c OR d)' }
  end

  describe 'a OR NOT b'  do
    subject { expr(:Or, 'a', expr(:Not, 'b')) }
    it { should express 'a OR -b' }
  end

  describe 'NOT a'  do
    subject { expr(:Not, 'a') }
    it { should express '-a' }
  end

  describe 'NOT (a OR b)'  do
    subject { expr(:Not, expr(:Or, 'a', 'b')) }
    it { should express '-(a OR b)' }
  end

  describe 'NOT (a AND b)'  do
    subject { expr(:Not, expr(:And, 'a', 'b')) }
    it { should express '-(a AND b)' }
  end

  describe 'a AND NOT (b OR c)'  do
    subject { expr(:And, 'a', expr(:Not, expr(:Or, 'b', 'c'))) }
    it { should express 'a AND -(b OR c)' }
  end

  describe 'a OR NOT (b AND c)'  do
    subject { expr(:Or, 'a', expr(:Not, expr(:And, 'b', 'c'))) }
    it { should express 'a OR -(b AND c)' }
  end
end
