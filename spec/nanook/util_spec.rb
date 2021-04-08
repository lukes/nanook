RSpec.describe Nanook::Util do
  subject do
    Class.new do
      include Nanook::Util
    end
  end

  it 'validate_unit! should allow valid units' do
    expect(subject.new.send(:validate_unit!, 'raw')).to eq(true)
    expect(subject.new.send(:validate_unit!, :raw)).to eq(true)
    expect(subject.new.send(:validate_unit!, 'nano')).to eq(true)
  end

  it 'validate_unit! should raise exception for invalid units' do
    expect { subject.new.send(:validate_unit!, 'foo') }.to raise_error(Nanook::NanoUnitError)
  end
end
