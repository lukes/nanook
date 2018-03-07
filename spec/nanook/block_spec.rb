require 'webmock/rspec'
require 'nanook/block'
WebMock.disable_net_connect!

describe Nanook::Block do

  let(:uri) { Nanook::Rpc::DEFAULT_URI }
  let(:block) { "000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F" }
  let(:headers) {
    {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby nanook gem'
    }
  }

  it "should request account correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block_account\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"account\":\"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\"}",
      headers: {}
    )

    Nanook.new.block(block).account
  end

  it "should request cancel_work correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"work_cancel\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{}",
      headers: {}
    )

    Nanook.new.block(block).cancel_work
  end

  it "should request chain correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"chain\",\"block\":\"#{block}\",\"count\":\"1000\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{}",
      headers: {}
    )

    Nanook.new.block(block).chain
  end

  it "should request chain with a limit correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"chain\",\"block\":\"#{block}\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{}",
      headers: {}
    )

    Nanook.new.block(block).chain(limit: 1)
  end

  it "should request generate_work correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"work_generate\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"work\":\"2bf29ef00786a6bc\"}",
      headers: {}
    )

    Nanook.new.block(block).generate_work
  end

  it "should request history correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"history\",\"hash\":\"#{block}\",\"count\":\"1000\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"history\":[{
        \"hash\":\"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\",
        \"type\":\"receive\",
        \"account\":\"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\",
        \"amount\":\"100000000000000000000000000000000\"
      }]}",
      headers: {}
    )

    Nanook.new.block(block).history
  end

  it "should request history with a limit correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"history\",\"hash\":\"#{block}\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"history\":[{
        \"hash\":\"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\",
        \"type\":\"receive\",
        \"account\":\"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\",
        \"amount\":\"100000000000000000000000000000000\"
      }]}",
      headers: {}
    )

    Nanook.new.block(block).history(limit: 1)
  end

  it "should request info correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"contents\":{
        \"type\":\"open\",
        \"account\":\"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\",
        \"representative\":\"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\",
        \"source\":\"FA5B51D063BADDF345EFD7EF0D3C5FB115C85B1EF4CDE89D8B7DF3EAF60A04A4\",
        \"work\":\"0000000000000000\",
        \"signature\":\"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000\"
    }}",
      headers: {}
    )

    Nanook.new.block(block).info
  end

  it "should request info allowing_unchecked when block is unchecked correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"unchecked_get\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"contents\":{
        \"type\":\"open\",
        \"account\":\"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\",
        \"representative\":\"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\",
        \"source\":\"FA5B51D063BADDF345EFD7EF0D3C5FB115C85B1EF4CDE89D8B7DF3EAF60A04A4\",
        \"work\":\"0000000000000000\",
        \"signature\":\"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000\"
    }}",
      headers: {}
    )

    Nanook.new.block(block).info(allow_unchecked: true)
  end

  it "should request info allowing_unchecked when block is not unchecked correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"unchecked_get\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{}",
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"block\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"contents\":{
        \"type\":\"open\",
        \"account\":\"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\",
        \"representative\":\"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\",
        \"source\":\"FA5B51D063BADDF345EFD7EF0D3C5FB115C85B1EF4CDE89D8B7DF3EAF60A04A4\",
        \"work\":\"0000000000000000\",
        \"signature\":\"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000\"
    }}",
      headers: {}
    )

    response = Nanook.new.block(block).info(allow_unchecked: true)
    expect(response[:contents][:account]).to eql("xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000")
  end

  it "should request republish correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"republish\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":[
        \"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
        \"A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293\"
     ]}",
      headers: {}
    )

    Nanook.new.block(block).republish
  end

  it "should raise execption if both sources and destinations arguments passed to republish" do
    expect{Nanook.new.block(block).republish(sources: 2, destinations: 2)}.to raise_error(ArgumentError)
  end

  it "should request republish with sources correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"republish\",\"hash\":\"#{block}\",\"sources\":\"2\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":[
        \"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
        \"A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293\"
     ]}",
      headers: {}
    )

    Nanook.new.block(block).republish(sources: 2)
  end

  it "should request republish with destinations correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"republish\",\"hash\":\"#{block}\",\"destinations\":\"2\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":[
        \"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
        \"A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293\"
     ]}",
      headers: {}
    )

    Nanook.new.block(block).republish(destinations: 2)
  end

  it "should request pending? correctly when block is pending" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending_exists\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"exists\":\"1\"}",
      headers: {}
    )

    expect(Nanook.new.block(block).pending?).to be true
  end

  it "should request pending? correctly when block is not pending" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending_exists\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"exists\":\"0\"}",
      headers: {}
    )

    expect(Nanook.new.block(block).pending?).to be false
  end

  it "should request process correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"process\",\"block\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"hash\":\"42A723D2B60462BF7C9A003FE9A70057D3A6355CA5F1D0A57581000000000000\"}",
      headers: {}
    )

    Nanook.new.block(block).process
  end

  it "should request successors correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"successors\",\"block\":\"#{block}\",\"count\":\"1000\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":[\"A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293\"]}",
      headers: {}
    )

    Nanook.new.block(block).successors
  end

  it "should request successors with limit correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"successors\",\"block\":\"#{block}\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":[\"A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293\"]}",
      headers: {}
    )

    Nanook.new.block(block).successors(limit: 1)
  end

  it "should request is_valid_work? correctly when valid" do
    work = "2bf29ef00786a6bc"

    stub_request(:post, uri).with(
      body: "{\"action\":\"work_validate\",\"hash\":\"#{block}\",\"work\":\"#{work}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"valid\":\"1\"}",
      headers: {}
    )

    expect(Nanook.new.block(block).is_valid_work?(work)).to be true
  end

  it "should request is_valid_work? correctly when not valid" do
    work = "2bf29ef00786a6bc"

    stub_request(:post, uri).with(
      body: "{\"action\":\"work_validate\",\"hash\":\"#{block}\",\"work\":\"#{work}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"valid\":\"0\"}",
      headers: {}
    )

    expect(Nanook.new.block(block).is_valid_work?(work)).to be false
  end

end
