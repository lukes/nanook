RSpec.describe Nanook::WalletAccount do

  let(:uri) { Nanook::Rpc::DEFAULT_URI }
  let(:account_id) { "xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000" }
  let(:wallet_id) { "000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F" }
  let(:block_id) { "000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F" }

  def stub_valid_account_check
    stub_request(:post, "http://localhost:7076/").
    with(
      body: "{\"action\":\"wallet_contains\",\"wallet\":\"#{wallet_id}\",\"account\":\"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\"}",
      headers: headers).
    to_return(status: 200, body: "{\"exists\":\"1\"}", headers: {})
  end

  def stub_account_exists_check
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_info\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"frontier\":\"FF84533A571D953A596EA401FD41743AC85D04F406E76FDE4408EAED50B473C5\",
      \"open_block\":\"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
      \"representative_block\":\"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
      \"balance\":\"23\",
      \"modified_timestamp\":\"1501793775\",
      \"block_count\":\"33\"}",
      headers: {}
    )
  end

  it "wallet account create" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_create\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"account\":\"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\"}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).account.create).to eq("xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000")
  end

  it "wallet account create with 0 as argument" do
    expect{Nanook.new.wallet(wallet_id).account.create(0)}.to raise_error(ArgumentError)
  end

  it "wallet account create with 5 as argument" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"accounts_create\",\"wallet\":\"#{wallet_id}\",\"count\":\"5\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"accounts\": [
        \"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\",
        \"xrb_1e5aqegc1jb7qe964u4adzmcezyo6o146zb8hm6dft8tkp79za3s00000000\",
        \"xrb_2e5aqegc1jb7qe964u4adzmcezyo6o146zb8hm6dft8tkp79za3s00000000\",
        \"xrb_3e5aqegc1jb7qe964u4adzmcezyo6o146zb8hm6dft8tkp79za3s00000000\",
        \"xrb_4e5aqegc1jb7qe964u4adzmcezyo6o146zb8hm6dft8tkp79za3s00000000\"
      ]}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).account.create(5)
    expect(response).to have(5).items
    expect(response[0]).to eq("xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000")
  end


  it "wallet account destroy" do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_remove\",\"wallet\":\"#{wallet_id}\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"removed\":\"1\"}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).account(account_id).destroy).to be true
  end

  it "wallet account send payment" do
    stub_valid_account_check
    stub_account_exists_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"send\",\"wallet\":\"#{wallet_id}\",\"source\":\"#{account_id}\",\"destination\":\"#{account_id}\",\"amount\":\"2000000000000000000000000000000\",\"id\":\"7081e2b8fec9146e\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"block\":\"#{block_id}\"}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).account(account_id).pay(to: account_id, amount: 2, id:"7081e2b8fec9146e")
    expect(response).to eq block_id
  end

  it "wallet account send payment in raw" do
    stub_valid_account_check
    stub_account_exists_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"send\",\"wallet\":\"#{wallet_id}\",\"source\":\"#{account_id}\",\"destination\":\"#{account_id}\",\"amount\":\"2\",\"id\":\"7081e2b8fec9146e\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"block\":\"#{block_id}\"}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).account(account_id).pay(to: account_id, amount: 2, unit: :raw, id:"7081e2b8fec9146e")
    expect(response).to eq block_id
  end

  it "wallet account receive latest pending payment" do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":[\"#{block_id}\"]}",
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"receive\",\"wallet\":\"#{wallet_id}\",\"account\":\"#{account_id}\",\"block\":\"#{block_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"block\":\"#{block_id}\"}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).account(account_id).receive).to eq block_id
  end

  it "wallet account receive latest pending payment when no payment is pending" do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":[]}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).account(account_id).receive).to be false
  end

  it "wallet account receive payment with block" do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"receive\",\"wallet\":\"#{wallet_id}\",\"account\":\"#{account_id}\",\"block\":\"#{block_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"block\":\"#{block_id}\"}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).account(account_id).receive(block_id)).to eq block_id
  end

  it "wallet account balance" do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_balance\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"balance\":\"2000000000000000000000000000\",\"pending\":\"1000000000000000000000000000\"}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).account(account_id).balance
    expect(response[:balance]).to eq(0.002)
    expect(response[:pending]).to eq(0.001)
  end

  it "wallet account balance raw unit" do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_balance\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"balance\":\"10000\",\"pending\":\"20000\"}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).account(account_id).balance(unit: :raw)
    expect(response[:balance]).to eq(10000)
    expect(response[:pending]).to eq(20000)
  end

  it "wallet account info" do
    stub_valid_account_check
    stub_account_exists_check

    expect(Nanook.new.wallet(wallet_id).account(account_id).info).to have_key(:frontier)
  end

  it "wallet account history" do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_history\",\"account\":\"#{account_id}\",\"count\":\"1000\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{
        \"history\": [{
                \"hash\": \"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\",
                \"type\": \"receive\",
                \"account\": \"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\",
                \"amount\": \"100000000000000000000000000000000\"
        }]
    }",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).account(account_id).history).to have(1).item
  end

  it "wallet account history without default count" do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_history\",\"account\":\"#{account_id}\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{
        \"history\": [{
                \"hash\": \"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\",
                \"type\": \"receive\",
                \"account\": \"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\",
                \"amount\": \"100000000000000000000000000000000\"
        }]
    }",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).account(account_id).history(limit: 1)).to have(1).item
  end

  it "wallet account representative" do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_representative\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"representative\":\"xrb_16u1uufyoig8777y6r8iqjtrw8sg8maqrm36zzcm95jmbd9i9aj5i8abr8u5\"}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).account(account_id).representative).to eq "xrb_16u1uufyoig8777y6r8iqjtrw8sg8maqrm36zzcm95jmbd9i9aj5i8abr8u5"
  end

  it "setting the wallet account representative" do
    stub_valid_account_check
    stub_account_exists_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_info\",\"account\":\"xrb_19a73oy5ungrhxy5z5oao1xso4zo7dmgpjd4u74xcrx3r1w6rtazuouw6qfi\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"frontier\":\"FF84533A571D953A596EA401FD41743AC85D04F406E76FDE4408EAED50B473C5\",
      \"open_block\":\"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
      \"representative_block\":\"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
      \"balance\":\"23\",
      \"modified_timestamp\":\"1501793775\",
      \"block_count\":\"33\"}",
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_representative_set\",\"wallet\":\"#{wallet_id}\",\"account\":\"#{account_id}\",\"representative\":\"xrb_19a73oy5ungrhxy5z5oao1xso4zo7dmgpjd4u74xcrx3r1w6rtazuouw6qfi\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"block\":\"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\"}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).account(account_id).change_representative("xrb_19a73oy5ungrhxy5z5oao1xso4zo7dmgpjd4u74xcrx3r1w6rtazuouw6qfi")
    expect(response).to eq "000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"
  end

  it "setting the wallet account representative if representative does not exist" do
    stub_valid_account_check
    stub_account_exists_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_info\",\"account\":\"xrb_19a73oy5ungrhxy5z5oao1xso4zo7dmgpjd4u74xcrx3r1w6rtazuouw6qfi\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"error\":\"Bad account number\"}",
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_representative_set\",\"wallet\":\"#{wallet_id}\",\"account\":\"#{account_id}\",\"representative\":\"xrb_19a73oy5ungrhxy5z5oao1xso4zo7dmgpjd4u74xcrx3r1w6rtazuouw6qfi\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"block\":\"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\"}",
      headers: {}
    )

    expect{Nanook.new.wallet(wallet_id).account(account_id).change_representative("xrb_19a73oy5ungrhxy5z5oao1xso4zo7dmgpjd4u74xcrx3r1w6rtazuouw6qfi")}.to raise_error(ArgumentError)
  end

  it "wallet account pending no limit" do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1000\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":[\"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\"]}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).account(account_id).pending).to have(1).item
  end

  it "wallet account pending when none are pending" do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1000\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":\"\"}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).account(account_id).pending).to eq []
  end

  it "wallet account pending with limit" do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":[\"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\"]}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).account(account_id).pending(limit: 1)).to have(1).item
  end

  it "wallet account weight" do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_weight\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"weight\":\"10000\"}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).account(account_id).weight).to eq 10000
  end

  it "wallet account ledger" do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"ledger\",\"account\":\"#{account_id}\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"accounts\": {
        \"xrb_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n\": {
          \"frontier\": \"E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321\",
          \"open_block\": \"643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F\",
          \"representative_block\": \"643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F\",
          \"balance\": \"0\",
          \"modified_timestamp\": \"1511476234\",
          \"block_count\": \"2\"
        }
      } }",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).account(account_id).ledger).to have_key :xrb_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n
  end

  it "wallet account ledger with limit" do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"ledger\",\"account\":\"#{account_id}\",\"count\":\"10\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"accounts\": {
        \"xrb_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n\": {
          \"frontier\": \"E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321\",
          \"open_block\": \"643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F\",
          \"representative_block\": \"643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F\",
          \"balance\": \"0\",
          \"modified_timestamp\": \"1511476234\",
          \"block_count\": \"2\"
        }
      } }",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).account(account_id).ledger(limit: 10)).to have_key :xrb_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n
  end

  it "wallet account exists? when exists" do
    stub_valid_account_check
    stub_account_exists_check

    expect(Nanook.new.wallet(wallet_id).account(account_id).exists?).to be true
  end

  it "wallet account exists? when doesn't exist" do
    stub_valid_account_check
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_info\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"error\":\"Bad account number\"}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).account(account_id).exists?).to be false
  end

  it "wallet account delegators" do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"delegators\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"delegators\": {
        \"xrb_13bqhi1cdqq8yb9szneoc38qk899d58i5rcrgdk5mkdm86hekpoez3zxw5sd\":\"500000000000000000000000000000000000\",
        \"xrb_17k6ug685154an8gri9whhe5kb5z1mf5w6y39gokc1657sh95fegm8ht1zpn\":\"961647970820730000000000000000000000\"
      }}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).account(account_id).delegators).to have_key :xrb_13bqhi1cdqq8yb9szneoc38qk899d58i5rcrgdk5mkdm86hekpoez3zxw5sd
  end

end
