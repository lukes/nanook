RSpec.describe Nanook do

  let(:uri) { Nanook::Rpc::DEFAULT_URI }
  let(:headers) {
    {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby nanook gem'
    }
  }

  it "should have a block method" do
    expect(Nanook.new.block("some_block")).to be_kind_of(Nanook::Block)
  end

  it "should have a key method" do
    expect(Nanook.new.key).to be_kind_of(Nanook::Key)
  end

  it "should have a node method" do
    expect(Nanook.new.node).to be_kind_of(Nanook::Node)
  end

  it "should have a wallet method" do
    expect(Nanook.new.wallet).to be_kind_of(Nanook::Wallet)
  end

  it "should have an account method" do
    expect(Nanook.new.account).to be_kind_of(Nanook::Account)
  end

  it "should have a work_peers method" do
    expect(Nanook.new.work_peers).to be_kind_of(Nanook::WorkPeer)
  end

  it "should have a rpc accessor" do
    expect(Nanook.new.rpc).to be_kind_of(Nanook::Rpc)
  end

end
