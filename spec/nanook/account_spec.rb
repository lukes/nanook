require 'webmock/rspec'
require 'nanook'
require 'nanook/account'
WebMock.disable_net_connect!

describe Nanook::Account do

  let(:uri) { Nanook::Rpc::DEFAULT_URI }
  let(:account_id) { "xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000" }
  let(:headers) {
    {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby nanook gem'
    }
  }

  it "account history requires account" do
    expect{Nanook.new.account(nil).history}.to raise_error(ArgumentError, "Account must be present")
  end

  it "account history" do
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

    Nanook.new.account(account_id).history
  end

  it "account history without default count" do
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

    Nanook.new.account(account_id).history(limit: 1)
  end

  it "account key" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_key\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"key\":\"3068BB1CA04525BB0E416C485FE6A67FD52540227D267CC8B6E8DA958A7FA039\"}",
      headers: {}
    )

    Nanook.new.account(account_id).public_key
  end

  it "account balance" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_balance\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"balance\":\"10000\",\"pending\":\"10000\"}",
      headers: {}
    )

    Nanook.new.account(account_id).balance
  end

  it "account representative" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_representative\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"representative\":\"xrb_16u1uufyoig8777y6r8iqjtrw8sg8maqrm36zzcm95jmbd9i9aj5i8abr8u5\"}",
      headers: {}
    )

    Nanook.new.account(account_id).representative
  end

  it "account info" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_info\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"frontier\":\"FF84533A571D953A596EA401FD41743AC85D04F406E76FDE4408EAED50B473C5\",
      \"open_block\":\"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
      \"representative_block\":\"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
      \"balance\":\"235580100176034320859259343606608761791\",
      \"modified_timestamp\":\"1501793775\",
      \"block_count\":\"33\"}",
      headers: {}
    )

    Nanook.new.account(account_id).info
  end

  it "account pending no limit" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1000\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":[\"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\"]}",
      headers: {}
    )

    Nanook.new.account(account_id).pending
  end

  it "account pending with limit" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":[\"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\"]}",
      headers: {}
    )

    Nanook.new.account(account_id).pending(limit: 1)
  end

  it "account weight" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_weight\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"weight\":\"10000\"}",
      headers: {}
    )

    Nanook.new.account(account_id).weight
  end

  it "account ledger" do
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

    Nanook.new.account(account_id).ledger
  end

  it "account ledger with limit" do
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

    Nanook.new.account(account_id).ledger(limit: 10)
  end

  it "account exists? when exists" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"validate_account_number\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"valid\":\"1\"}",
      headers: {}
    )

    expect(Nanook.new.account(account_id).exists?).to be true
  end

  it "account exists? when doesn't exist" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"validate_account_number\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"valid\":\"0\"}",
      headers: {}
    )

    expect(Nanook.new.account(account_id).exists?).to be false
  end

  it "account delegators" do
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

    Nanook.new.account(account_id).delegators
  end

end
