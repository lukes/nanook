RSpec.describe Nanook::Block do

  let(:uri) { Nanook::Rpc::DEFAULT_URI }
  let(:block) { "000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F" }

  it "should request account correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block_account\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"account\":\"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\"}",
      headers: {}
    )

    expect(Nanook.new.block(block).account).to eq "xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000"
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

    expect(Nanook.new.block(block).cancel_work).to be true
  end

  it "should request chain correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"chain\",\"block\":\"#{block}\",\"count\":\"1000\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":[\"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\"]}",
      headers: {}
    )

    expect(Nanook.new.block(block).chain).to have(1).item
  end

  it "should request chain and when no blocks (empty string response) return an array" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"chain\",\"block\":\"#{block}\",\"count\":\"1000\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":\"\"}",
      headers: {}
    )

    expect(Nanook.new.block(block).chain).to eq []
  end

  it "should request chain with a limit correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"chain\",\"block\":\"#{block}\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":[\"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\"]}",
      headers: {}
    )

    expect(Nanook.new.block(block).chain(limit: 1)).to have(1).item
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

    expect(Nanook.new.block(block).generate_work).to eq "2bf29ef00786a6bc"
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

    expect(Nanook.new.block(block).history).to have(1).item
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

    expect(Nanook.new.block(block).history(limit: 1)).to have(1).item
  end

  it "should request info correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"contents\":\"{\\n    \\\"type\\\": \\\"receive\\\",\\n    \\\"previous\\\": \\\"1B5D8610485FE5E764EA08D4C745B244D9C173647FBFA79C26D3902A439C9688\\\",\\n    \\\"source\\\": \\\"F8D4214945C23CB8BD69230A16C85C3ED831CE17107B5C4CC5AA1F68B10EC72C\\\",\\n    \\\"work\\\": \\\"633cdda00b9f7265\\\",\\n    \\\"signature\\\": \\\"4E5CAAE4556FB2417DE1788B3A5A12B6EFD1811B00A69F4761F0FFD5F9C88FBD653563BDA206753AE3915CA1A4EC804C923DAA3C33580224F138E62805528B06\\\"\\n}\\n\"}",
      headers: {}
    )

    expect(Nanook.new.block(block).info).to have_key(:type)
  end

  it "should return block not found correctly on info" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"error\":\"Block not found\"}",
      headers: {}
    )

    expect(Nanook.new.block(block).info).to have_key(:error)
  end

  it "should request info allowing_unchecked when block is unchecked correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"unchecked_get\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"contents\":\"{\\n    \\\"type\\\": \\\"receive\\\",\\n    \\\"previous\\\": \\\"1B5D8610485FE5E764EA08D4C745B244D9C173647FBFA79C26D3902A439C9688\\\",\\n    \\\"source\\\": \\\"F8D4214945C23CB8BD69230A16C85C3ED831CE17107B5C4CC5AA1F68B10EC72C\\\",\\n    \\\"work\\\": \\\"633cdda00b9f7265\\\",\\n    \\\"signature\\\": \\\"4E5CAAE4556FB2417DE1788B3A5A12B6EFD1811B00A69F4761F0FFD5F9C88FBD653563BDA206753AE3915CA1A4EC804C923DAA3C33580224F138E62805528B06\\\"\\n}\\n\"}",
      headers: {}
    )

    expect(Nanook.new.block(block).info(allow_unchecked: true)).to have_key(:type)
  end

  it "should request info allowing_unchecked when block is not unchecked correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"unchecked_get\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"error\":\"Block not found\"}",
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"block\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"contents\":\"{\\n    \\\"type\\\": \\\"receive\\\",\\n    \\\"previous\\\": \\\"1B5D8610485FE5E764EA08D4C745B244D9C173647FBFA79C26D3902A439C9688\\\",\\n    \\\"source\\\": \\\"F8D4214945C23CB8BD69230A16C85C3ED831CE17107B5C4CC5AA1F68B10EC72C\\\",\\n    \\\"work\\\": \\\"633cdda00b9f7265\\\",\\n    \\\"signature\\\": \\\"4E5CAAE4556FB2417DE1788B3A5A12B6EFD1811B00A69F4761F0FFD5F9C88FBD653563BDA206753AE3915CA1A4EC804C923DAA3C33580224F138E62805528B06\\\"\\n}\\n\"}",
      headers: {}
    )

    expect(Nanook.new.block(block).info(allow_unchecked: true)).to have_key(:work)
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

    expect(Nanook.new.block(block).republish).to have(2).items
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

    expect(Nanook.new.block(block).republish(sources: 2)).to have(2).items
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

    Nanook.new.block(block).publish
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

    expect(Nanook.new.block(block).successors).to have(1).item
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

    expect(Nanook.new.block(block).successors(limit: 1)).to have(1).item
  end

  it "should request successors when there are none (empty string response) and return blank array" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"successors\",\"block\":\"#{block}\",\"count\":\"1000\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":\"\"}",
      headers: {}
    )

    expect(Nanook.new.block(block).successors(limit: 1000)).to be_empty
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
