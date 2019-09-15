RSpec.describe Nanook::Wallet do

  let(:uri) { Nanook::Rpc::DEFAULT_URI }
  let(:account_id) { "nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000" }
  let(:wallet_id) { "000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F" }
  let(:block_id) { "000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F" }

  def stub_valid_account_check
    stub_request(:post, "http://localhost:7076/").
    with(
      body: "{\"action\":\"wallet_contains\",\"wallet\":\"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\",\"account\":\"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\"}",
      headers: {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby nanook gem'
      }).
    to_return(status: 200, body: "{\"exists\":\"1\"}", headers: {})
  end

  it "should have an account method" do
    expect(Nanook.new.wallet(wallet_id).account).to be_kind_of(Nanook::WalletAccount)
  end

  it "wallet accounts" do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_list\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"accounts\":[\"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\"]}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).accounts
    expect(response).to have(1).item
    expect(response.first).to be_kind_of Nanook::WalletAccount
    expect(response.first.id).to eq "nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000"
  end

  it "wallet accounts when blank" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_list\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"accounts\":\"\"}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).accounts).to eq []
  end

  it "wallet create" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_create\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"wallet\":\"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\"}",
      headers: {}
    )

    response = Nanook.new.wallet.create
    expect(response).to be_kind_of Nanook::Wallet
    expect(response.id).to eq "000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"
  end

  it "wallet destroy" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_destroy\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).destroy).to be true
  end

  it "wallet export" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_export\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"json\":\"{\\\"0000000000000000000000000000000000000000000000000000000000000000\\\": \\\"0000000000000000000000000000000000000000000000000000000000000001\\\"}\"}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).export).to eq '{"0000000000000000000000000000000000000000000000000000000000000000": "0000000000000000000000000000000000000000000000000000000000000001"}'
  end

  it "wallet contains? when true" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_contains\",\"wallet\":\"#{wallet_id}\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"exists\":\"1\"}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).contains?(account_id)).to be true
  end

  it "wallet contains? when false" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_contains\",\"wallet\":\"#{wallet_id}\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"exists\":\"0\"}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).contains?(account_id)).to be false
  end

  it "wallet lock" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_lock\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"locked\":\"1\"}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).lock).to be true
  end

  it "wallet locked? when it is not locked" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_locked\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"locked\":\"0\"}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).locked?).to be false
  end

  it "wallet locked? when it is locked" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_locked\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"locked\":\"1\"}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).locked?).to be true
  end

  it "wallet unlock" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"password_enter\",\"wallet\":\"#{wallet_id}\",\"password\":\"test\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"valid\":\"1\"}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).unlock("test")).to be true
  end

  it "wallet change password" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"password_change\",\"wallet\":\"#{wallet_id}\",\"password\":\"test\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"changed\":\"1\"}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).change_password("test")).to be true
  end

  it "wallet send payment" do
    stub_valid_account_check

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

    stub_request(:post, uri).with(
      body: "{\"action\":\"validate_account_number\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"valid\":\"1\"}",
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"send\",\"wallet\":\"#{wallet_id}\",\"source\":\"#{account_id}\",\"destination\":\"#{account_id}\",\"amount\":\"2000000000000000000000000000000\",\"id\":\"7081e2b8fec9146e\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"block\":\"#{block_id}\"}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).pay(from: account_id, to: account_id, amount: 2, id:"7081e2b8fec9146e")
    expect(response).to eq block_id
  end

  it "wallet send payment in raw" do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"validate_account_number\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"valid\":\"1\"}",
      headers: {}
    )

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

    stub_request(:post, uri).with(
      body: "{\"action\":\"send\",\"wallet\":\"#{wallet_id}\",\"source\":\"#{account_id}\",\"destination\":\"#{account_id}\",\"amount\":\"2\",\"id\":\"7081e2b8fec9146e\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"block\":\"#{block_id}\"}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).pay(from: account_id, to: account_id, amount: 2, unit: :raw, id:"7081e2b8fec9146e")
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

    response = Nanook.new.wallet(wallet_id).receive(into: account_id)
    expect(response).to eq block_id
  end

  it "wallet account receive latest pending payment when no payment is pending" do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":\"\"}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).receive(into: account_id)).to be false
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

    response = Nanook.new.wallet(wallet_id).receive(block_id, into: account_id)
    expect(response).to eq block_id
  end

  it "wallet balance with account break down" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_balances\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"balances\":{
        \"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\":{
          \"balance\":\"1000000000000000000000000000\",
          \"pending\":\"2000000000000000000000000000\"
        }
      }}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).balance(account_break_down: true)
    expect(response).to have_key :nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000
    expect(response[:nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000][:balance]).to eq(0.001)
    expect(response[:nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000][:pending]).to eq(0.002)
  end

  it "wallet balance with account break down and unit raw" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_balances\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"balances\":{
        \"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\":{
          \"balance\":\"1000000000000000000000000000\",
          \"pending\":\"2000000000000000000000000000\"
        }
      }}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).balance(account_break_down: true, unit: :raw)
    expect(response).to have_key :nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000
    expect(response[:nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000][:balance]).to eq(1000000000000000000000000000)
    expect(response[:nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000][:pending]).to eq(2000000000000000000000000000)
  end

  it "wallet balance with no account break down" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_balance_total\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"balance\":\"1000000000000000000000000000\",\"pending\":\"2000000000000000000000000000\"}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).balance
    expect(response[:balance]).to eq(0.001)
    expect(response[:pending]).to eq(0.002)
  end

  it "wallet balance with no account break down in raw" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_balance_total\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"balance\":\"1000000000000000000000000000\",\"pending\":\"2000000000000000000000000000\"}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).balance(unit: :raw)
    expect(response[:balance]).to eq(1000000000000000000000000000)
    expect(response[:pending]).to eq(2000000000000000000000000000)
  end

  it "wallet restore with no accounts" do
    seed = "000F2BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"

    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_create\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"wallet\":\"#{wallet_id}\"}",
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_change_seed\",\"wallet\":\"#{wallet_id}\",\"seed\":\"#{seed}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"success\":\"\"}",
      headers: {}
    )

    response = Nanook.new.wallet.restore(seed)
    expect(response).to be_kind_of Nanook::Wallet
    expect(response.id).to eq wallet_id
  end

  it "wallet restore with 1 account" do
    seed = "000F2BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"

    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_create\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"wallet\":\"#{wallet_id}\"}",
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_change_seed\",\"wallet\":\"#{wallet_id}\",\"seed\":\"#{seed}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"success\":\"\"}",
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_create\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"account\":\"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\"}",
      headers: {}
    )

    stub_request(:post, "http://localhost:7076/").
    with(
      body: "{\"action\":\"wallet_contains\",\"wallet\":\"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\",\"account\":\"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\"}",
      headers: {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby nanook gem'
      }).
    to_return(status: 200, body: "{\"exists\":\"1\"}", headers: {})

    response = Nanook.new.wallet.restore(seed, accounts: 1)
    expect(response).to be_kind_of Nanook::Wallet
    expect(response.id).to eq wallet_id
  end

  it "wallet pending with default limit" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_pending\",\"wallet\":\"#{wallet_id}\",\"count\":\"1000\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\" : {
        \"nano_1111111111111111111111111111111111111111111111111117353trpda\": [\"142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D\",\"142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D\"],
        \"nano_3t6k35gi95xu6tergt6p69ck76ogmitsa8mnijtpxm9fkcm736xtoncuohr3\": [\"4C1FEEF0BEA7F50BE35489A1233FE002B212DEA554B55B1B470D78BD8F210C74\"]
      }}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).pending
    expect(response.keys).to have(2).items
    expect(response["nano_1111111111111111111111111111111111111111111111111117353trpda"]).to have(2).items
    expect(response["nano_3t6k35gi95xu6tergt6p69ck76ogmitsa8mnijtpxm9fkcm736xtoncuohr3"]).to have(1).item
  end

  it "wallet pending with limit" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_pending\",\"wallet\":\"#{wallet_id}\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\": {
        \"nano_1111111111111111111111111111111111111111111111111117353trpda\": [\"142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D\",\"142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D\"]
      }}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).pending(limit: 1)
    expect(response.keys).to have(1).items
    expect(response["nano_1111111111111111111111111111111111111111111111111117353trpda"]).to have(2).items
  end

  it "wallet pending with detailed" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_pending\",\"wallet\":\"#{wallet_id}\",\"count\":\"1000\",\"source\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\": {
        \"nano_1111111111111111111111111111111111111111111111111117353trpda\": {
            \"142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D\": {
                 \"amount\": \"6000000000000000000000000000000\",
                 \"source\": \"nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr\"
            },
            \"242A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D\": {
                 \"amount\": \"12000000000000000000000000000000\",
                 \"source\": \"nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr\"
            }
        },
        \"nano_3t6k35gi95xu6tergt6p69ck76ogmitsa8mnijtpxm9fkcm736xtoncuohr3\": {
            \"4C1FEEF0BEA7F50BE35489A1233FE002B212DEA554B55B1B470D78BD8F210C74\": {
                 \"amount\": \"106370018000000000000000000000000\",
                 \"source\": \"nano_13ezf4od79h1tgj9aiu4djzcmmguendtjfuhwfukhuucboua8cpoihmh8byo\"
            }
        }
      }}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).pending(detailed: true)
    expect(response.keys).to have(2).items
    expect(response["nano_1111111111111111111111111111111111111111111111111117353trpda"]).to have(2).items
    expect(response["nano_1111111111111111111111111111111111111111111111111117353trpda"][0][:amount]).to eq 6
    expect(response["nano_1111111111111111111111111111111111111111111111111117353trpda"][0][:source]).to eq "nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr"
    expect(response["nano_1111111111111111111111111111111111111111111111111117353trpda"][0][:block]).to eq "142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D"
  end

  it "wallet pending with detailed and unit raw" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_pending\",\"wallet\":\"#{wallet_id}\",\"count\":\"1000\",\"source\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\": {
        \"nano_1111111111111111111111111111111111111111111111111117353trpda\": {
            \"142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D\": {
                 \"amount\": \"6000000000000000000000000000000\",
                 \"source\": \"nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr\"
            },
            \"242A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D\": {
                 \"amount\": \"12000000000000000000000000000000\",
                 \"source\": \"nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr\"
            }
        },
        \"nano_3t6k35gi95xu6tergt6p69ck76ogmitsa8mnijtpxm9fkcm736xtoncuohr3\": {
            \"4C1FEEF0BEA7F50BE35489A1233FE002B212DEA554B55B1B470D78BD8F210C74\": {
                 \"amount\": \"106370018000000000000000000000000\",
                 \"source\": \"nano_13ezf4od79h1tgj9aiu4djzcmmguendtjfuhwfukhuucboua8cpoihmh8byo\"
            }
        }
      }}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).pending(detailed: true, unit: :raw)
    expect(response.keys).to have(2).items
    expect(response["nano_1111111111111111111111111111111111111111111111111117353trpda"]).to have(2).items
    expect(response["nano_1111111111111111111111111111111111111111111111111117353trpda"][0][:amount]).to eq 6000000000000000000000000000000
    expect(response["nano_1111111111111111111111111111111111111111111111111117353trpda"][0][:source]).to eq "nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr"
    expect(response["nano_1111111111111111111111111111111111111111111111111117353trpda"][0][:block]).to eq "142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D"
  end

  it "wallet default_representative" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_representative\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"representative\":\"nano_16u1uufyoig8777y6r8iqjtrw8sg8maqrm36zzcm95jmbd9i9aj5i8abr8u5\"}",
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).default_representative).to eq "nano_16u1uufyoig8777y6r8iqjtrw8sg8maqrm36zzcm95jmbd9i9aj5i8abr8u5"
  end

  it "wallet change_default_representative" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_representative_set\",\"wallet\":\"#{wallet_id}\",\"representative\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"set\": \"1\"}",
      headers: {}
    )

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

    response = Nanook.new.wallet(wallet_id).change_default_representative(account_id)
    expect(response).to be account_id
  end

  it "wallet change_representative when representative does not exist" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_info\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"error\":\"Bad account number\"}",
      headers: {}
    )

    expect{ Nanook.new.wallet(wallet_id).change_default_representative(account_id) }.to raise_error(ArgumentError)
  end

  it "wallet info" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_ledger\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"accounts\": {
        \"nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n\": {
          \"frontier\": \"E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321\",
          \"open_block\": \"643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F\",
          \"representative_block\": \"643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F\",
          \"balance\": \"124000000000000000000000000000\",
          \"modified_timestamp\": \"1511476234\",
          \"block_count\": \"2\"
        }
      }  }",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).info
    expect(response[:id]).to eq wallet_id
    expect(response[:accounts]).to have(1).item
    expect(response[:accounts][0][:frontier]).to eq("E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321")
    expect(response[:accounts][0][:open_block]).to eq("643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F")
    expect(response[:accounts][0][:representative_block]).to eq("643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F")
    expect(response[:accounts][0][:balance]).to eq(0.124)
    expect(response[:accounts][0][:modified_timestamp]).to eq(1511476234)
    expect(response[:accounts][0][:block_count]).to eq(2)
  end

  it "wallet info with unit arg" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_ledger\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"accounts\": {
        \"nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n\": {
          \"frontier\": \"E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321\",
          \"open_block\": \"643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F\",
          \"representative_block\": \"643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F\",
          \"balance\": \"124000000000000000000000000000\",
          \"modified_timestamp\": \"1511476234\",
          \"block_count\": \"2\"
        }
      }  }",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).info(unit: :raw)
    expect(response[:id]).to eq wallet_id
    expect(response[:accounts]).to have(1).item
    expect(response[:accounts][0][:frontier]).to eq("E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321")
    expect(response[:accounts][0][:open_block]).to eq("643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F")
    expect(response[:accounts][0][:representative_block]).to eq("643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F")
    expect(response[:accounts][0][:balance]).to eq(124000000000000000000000000000)
    expect(response[:accounts][0][:modified_timestamp]).to eq(1511476234)
    expect(response[:accounts][0][:block_count]).to eq(2)
  end

end
