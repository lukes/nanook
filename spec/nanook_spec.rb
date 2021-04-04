# frozen_string_literal: true

RSpec.describe Nanook do
  let(:uri) { Nanook::Rpc::DEFAULT_URI }
  let(:headers) do
    {
      'Accept' => '*/*',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type' => 'application/json',
      'User-Agent' => 'Ruby nanook gem'
    }
  end

  it 'default_unit class method should return :nano by default' do
    expect(Nanook.default_unit).to eq(:nano)
  end

  it 'default_unit class method should return Nanook::UNIT if defined' do
    silent_warnings do
      Nanook::UNIT = :raw
      expect(Nanook.default_unit).to eq(:raw)
      Nanook::UNIT = :nano # reset
    end
  end

  it 'default_unit class method should raise Nanook::Error if Nanook::UNIT is not one of Nanook::UNITS' do
    silent_warnings do
      Nanook::UNIT = :invalid
      expect { Nanook.default_unit }.to raise_error(Nanook::Error)
      Nanook::UNIT = :nano # reset
    end
  end

  it 'should have a block method' do
    expect(Nanook.new.block('some_block')).to be_kind_of(Nanook::Block)
  end

  it 'should have a key method' do
    expect(Nanook.new.key).to be_kind_of(Nanook::Key)
  end

  it 'should have a node method' do
    expect(Nanook.new.node).to be_kind_of(Nanook::Node)
  end

  it 'should have a wallet method' do
    expect(Nanook.new.wallet).to be_kind_of(Nanook::Wallet)
  end

  it 'should have an account method' do
    expect(Nanook.new.account('some_account')).to be_kind_of(Nanook::Account)
  end

  it 'should have a work_peers method' do
    expect(Nanook.new.work_peers).to be_kind_of(Nanook::WorkPeer)
  end

  it 'should have a rpc accessor' do
    expect(Nanook.new.rpc).to be_kind_of(Nanook::Rpc)
  end
end
