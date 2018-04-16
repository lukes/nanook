RSpec.describe Nanook::Node do

  let(:uri) { Nanook::Rpc::DEFAULT_URI }

  it "should request account_count correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"frontier_count\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"count\":\"1000\"}",
      headers: {}
    )

    expect(Nanook.new.node.account_count).to eq 1000
  end

  it "should request block_count correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block_count\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"count\":\"1000\",\"unchecked\":\"10\"}",
      headers: {}
    )

    expect(Nanook.new.node.block_count).to have_key(:count)
  end

  it "should request block_count_by_type correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block_count_type\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"send\":\"1000\",\"receive\":\"900\",\"open\":\"100\",\"change\":\"50\"}",
      headers: {}
    )

    expect(Nanook.new.node.block_count_by_type).to have_key(:send)
  end

  it "should request bootstrap correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"bootstrap\",\"address\":\"::ffff:138.201.94.249\",\"port\":\"7075\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"success\":\"\"}",
      headers: {}
    )

    expect(Nanook.new.node.bootstrap(address: "::ffff:138.201.94.249", port: "7075")).to be true
  end

  it "should request bootstrap correctly when error" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"bootstrap\",\"address\":\"::ffff:138.201.94.249\",\"port\":\"7075\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"error\":\"\"}",
      headers: {}
    )

    expect(Nanook.new.node.bootstrap(address: "::ffff:138.201.94.249", port: "7075")).to be false
  end

  it "should request bootstrap_any correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"bootstrap_any\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"success\":\"\"}",
      headers: {}
    )

    expect(Nanook.new.node.bootstrap_any).to be true
  end

  it "should request bootstrap_any correctly when error" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"bootstrap_any\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"error\":\"\"}",
      headers: {}
    )

    expect(Nanook.new.node.bootstrap_any).to be false
  end

  it "should request representatives correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"representatives\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"representatives\":{\"xrb_1111111111111111111111111111111111111111111111111117353trpda\":\"3822372327060170000000000000000000000\",\"xrb_1111111111111111111111111111111111111111111111111awsq94gtecn\":\"30999999999999999999999999000000\",\"xrb_114nk4rwjctu6n6tr6g6ps61g1w3hdpjxfas4xj1tq6i8jyomc5d858xr1xi\":\"0\"}}",
      headers: {}
    )

    response = Nanook.new.node.representatives
    expect(response).to have_key(:xrb_1111111111111111111111111111111111111111111111111117353trpda)
    expect(response[:xrb_1111111111111111111111111111111111111111111111111117353trpda]).to eq(3822372.32706017)
  end

  it "should request representatives with unit correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"representatives\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"representatives\":{\"xrb_1111111111111111111111111111111111111111111111111117353trpda\":\"3822372327060170000000000000000000000\",\"xrb_1111111111111111111111111111111111111111111111111awsq94gtecn\":\"30999999999999999999999999000000\",\"xrb_114nk4rwjctu6n6tr6g6ps61g1w3hdpjxfas4xj1tq6i8jyomc5d858xr1xi\":\"0\"}}",
      headers: {}
    )

    response = Nanook.new.node.representatives(unit: :raw)
    expect(response).to have_key(:xrb_1111111111111111111111111111111111111111111111111117353trpda)
    expect(response[:xrb_1111111111111111111111111111111111111111111111111117353trpda]).to eq(3822372327060170000000000000000000000)
  end

  it "should request peers correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"peers\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"peers\":{\"[::ffff:172.17.0.1]:32841\":\"3\"}}",
      headers: {}
    )

    expect(Nanook.new.node.peers).to have_key("[::ffff:172.17.0.1]:32841")
  end

  it "should request stop correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"stop\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"success\":\"\"}",
      headers: {}
    )

    expect(Nanook.new.node.stop).to be true
  end

  it "should request version correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"version\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"rpc_version\":\"1\",\"store_version\":\"2\",\"node_vendor\":\"RaiBlocks 7.5.0\"}",
      headers: {}
    )

    expect(Nanook.new.node.version).to have_key(:rpc_version)
  end

  it "should request frontier_count correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"frontier_count\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"count\":\"100\"}",
      headers: {}
    )

    # frontier_count is an alias of account_count
    expect(Nanook.new.node.frontier_count).to eq 100
  end

  it "should show block_count progress as a percentage with sync_process" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block_count\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"count\":\"1000\",\"unchecked\":\"5\"}",
      headers: {}
    )

    expect(Nanook.new.node.sync_progress).to eq 99.50248756218906
  end

  it "should show synchronizing_blocks" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"unchecked\",\"count\":\"1000\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":{\"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\":\"{\\\"type\\\": \\\"open\\\",\\\"account\\\": \\\"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\\\",\\\"representative\\\": \\\"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\\\",\\\"source\\\": \\\"FA5B51D063BADDF345EFD7EF0D3C5FB115C85B1EF4CDE89D8B7DF3EAF60A04A4\\\",\\\"work\\\": \\\"0000000000000000\\\",\\\"signature\\\":\\\"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000\\\"}\",\"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3C\":\"{\\\"type\\\": \\\"open\\\",\\\"account\\\": \\\"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\\\",\\\"representative\\\": \\\"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\\\",\\\"source\\\": \\\"FA5B51D063BADDF345EFD7EF0D3C5FB115C85B1EF4CDE89D8B7DF3EAF60A04A4\\\",\\\"work\\\": \\\"0000000000000000\\\",\\\"signature\\\":\\\"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000\\\"}\"}}",
      headers: {}
    )

    response = Nanook.new.node.synchronizing_blocks

    expect(response).to have(2).items

    block = response["000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"]

    expect(block[:type]).to eq "open"
    expect(block[:account]).to eq "xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000"
    expect(block[:representative]).to eq "xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000"
    expect(block[:source]).to eq "FA5B51D063BADDF345EFD7EF0D3C5FB115C85B1EF4CDE89D8B7DF3EAF60A04A4"
    expect(block[:work]).to eq "0000000000000000"
    expect(block[:signature]).to eq "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
  end

  it "should show synchronizing_blocks with limit" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"unchecked\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\": {\"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\": \"{\\\"type\\\": \\\"open\\\",\\\"account\\\": \\\"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\\\",\\\"representative\\\": \\\"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\\\",\\\"source\\\": \\\"FA5B51D063BADDF345EFD7EF0D3C5FB115C85B1EF4CDE89D8B7DF3EAF60A04A4\\\",\\\"work\\\": \\\"0000000000000000\\\",\\\"signature\\\":\\\"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000\\\"}\"}}",
      headers: {}
    )

    response = Nanook.new.node.synchronizing_blocks(limit: 1)

    expect(response).to have(1).item

    block = response["000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"]

    expect(block[:type]).to eq "open"
    expect(block[:account]).to eq "xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000"
    expect(block[:representative]).to eq "xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000"
    expect(block[:source]).to eq "FA5B51D063BADDF345EFD7EF0D3C5FB115C85B1EF4CDE89D8B7DF3EAF60A04A4"
    expect(block[:work]).to eq "0000000000000000"
    expect(block[:signature]).to eq "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
  end

  it "should synced? when true" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block_count\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"count\":\"1000\",\"unchecked\":\"0\"}",
      headers: {}
    )

    expect(Nanook.new.node.synced?).to be true
  end

  it "should synced? when false" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block_count\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"count\":\"1000\",\"unchecked\":\"5\"}",
      headers: {}
    )

    expect(Nanook.new.node.synced?).to be false
  end

end
