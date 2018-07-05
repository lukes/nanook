class Nanook

  # The <tt>Nanook::Node</tt> class contains methods to manage your nano
  # node and query its data of the nano network.
  #
  # Your node is constantly syncing data with other nodes on the network. When
  # your node first starts up after being built, its database will be empty
  # and it will begin synchronizing and downloading data of the nano ledger
  # to its local database. The ledger is the central record of all accounts
  # and transactions. Some of the methods in this class query your node's
  # database formed from the nano ledger, and so the responses are determined
  # by the completeness of your node's database.
  #
  # You can determine how synchronized your node is with the nano ledger
  # with the {#sync_progress} method.
  #
  # === Initializing
  #
  # Initialize this class through the convenient {Nanook#node} method:
  #
  #   node = Nanook.new.node
  #
  # Or compose the longhand way like this:
  #
  #   rpc_conn = Nanook::Rpc.new
  #   node = Nanook::Node.new(rpc_conn)
  class Node

    def initialize(rpc)
      @rpc = rpc
    end

    # The number of accounts in the nano ledger--essentially all
    # accounts with _open_ blocks. An _open_ block
    # is the type of block written to the nano ledger when an account
    # receives its first payment (see {Nanook::WalletAccount#receive}). All accounts
    # that respond +true+ to {Nanook::Account#exists?} have open blocks in the ledger.
    #
    # @return [Integer] number of accounts with _open_ blocks.
    def account_count
      rpc(:frontier_count)[:count]
    end
    alias_method :frontier_count, :account_count

    # The count of all blocks downloaded to the node, and
    # blocks still to be synchronized by the node.
    #
    # ==== Example:
    #
    #
    #
    # @return [Hash{Symbol=>Integer}] number of blocks and unchecked
    #   synchronizing blocks
    def block_count
      rpc(:block_count)
    end

    # The count of all known blocks by their type.
    #
    # ==== Example:
    #
    #   node.block_count_by_type
    #
    # Example response:
    #
    #   {
    #     send: 1000,
    #     receive: 900,
    #     open: 900,
    #     change: 50
    #   }
    #
    # @return [Hash{Symbol=>Integer}] number of blocks by type
    def block_count_by_type
      rpc(:block_count_type)
    end
    alias_method :block_count_type, :block_count_by_type

    # Initialize bootstrap to a specific IP address and port.
    #
    # @return [Boolean] indicating if the action was successful
    def bootstrap(address:, port:)
      rpc(:bootstrap, address: address, port: port).has_key?(:success)
    end

    # Initialize multi-connection bootstrap to random peers
    #
    # @return [Boolean] indicating if the action was successful
    def bootstrap_any
      rpc(:bootstrap_any).has_key?(:success)
    end

    # Returns block and tally weight (in raw) for recent elections winners
    #
    # ==== Example:
    #
    #   node.confirmation_history
    #
    # Example response:
    #
    #   [
    #     {
    #       block: "EA70B32C55C193345D625F766EEA2FCA52D3F2CCE0B3A30838CC543026BB0FEA",
    #       tally: 80394786589602980996311817874549318248
    #     },
    #     {
    #       block: "F2F8DA6D2CA0A4D78EB043A7A29E12BDE5B4CE7DE1B99A93A5210428EE5B8667",
    #       tally: 68921714529890443063672782079965877749
    #     }
    #   ]
    #
    # @return [Hash{Symbol=>String|Integer}]
    def confirmation_history
      rpc(:confirmation_history)[:confirmations].map do |history|
        # Rename hash key to block
        block = history.delete(:hash)
        {block: block}.merge(history)
      end
    end

    # @return [String]
    def inspect
      "#{self.class.name}(object_id: \"#{"0x00%x" % (object_id << 1)}\")"
    end

    def peers
      rpc(:peers)[:peers]
    end

    # All representatives and their voting weight.
    #
    # ==== Example:
    #
    #   node.representatives
    #
    # Example response:
    #
    #   {
    #     xrb_1111111111111111111111111111111111111111111111111117353trpda: 3822372327060170000000000000000000000,
    #     xrb_1111111111111111111111111111111111111111111111111awsq94gtecn: 30999999999999999999999999000000,
    #     xrb_114nk4rwjctu6n6tr6g6ps61g1w3hdpjxfas4xj1tq6i8jyomc5d858xr1xi: 0
    #   }
    #
    # @return [Hash{Symbol=>Integer}] known representatives and their voting weight
    def representatives(unit: Nanook.default_unit)
      unless Nanook::UNITS.include?(unit)
        raise ArgumentError.new("Unsupported unit: #{unit}")
      end

      response = rpc(:representatives)[:representatives]
      return response if unit == :raw

      r = response.map do |account_id, balance|
        balance = Nanook::Util.raw_to_NANO(balance)

        [account_id, balance]
      end

      Hash[r].to_symbolized_hash
    end

    # All online representatives that have voted recently. Note, due to the
    # design of the nano RPC, this method cannot return the voting weight
    # of the representatives.
    #
    # ==== Example:
    #
    #   node.representatives_online # => ["xrb_111...", "xrb_222"]
    #
    # @return [Array<String>] array of representative account ids
    def representatives_online
      response = rpc(:representatives_online)[:representatives].keys.map(&:to_s)
    end

    # Safely shuts down the node.
    #
    # @return [Boolean] indicating if action was successful
    def stop
      rpc(:stop).has_key?(:success)
    end

    # @param limit [Integer] number of synchronizing blocks to return
    # @return [Hash{Symbol=>String}] information about the synchronizing blocks for this node
    def synchronizing_blocks(limit: 1000)
      response = rpc(:unchecked, count: limit)[:blocks]
      response = response.map do |block, info|
        [block, JSON.parse(info).to_symbolized_hash]
      end
      Hash[response.sort].to_symbolized_hash
    end
    alias_method :unchecked, :synchronizing_blocks

    # The percentage completeness of the synchronization process for
    # your node as it downloads the nano ledger. Note, it's normal for
    # your progress to not ever reach 100. The closer to 100, the more
    # complete your node's data is, and so the query methods in this class
    # become more reliable.
    #
    # @return [Float] the percentage completeness of the synchronization
    #   process for your node
    def sync_progress
      response = rpc(:block_count)

      count = response[:count]
      unchecked = response[:unchecked]
      total =  count + unchecked

      count.to_f * 100 / total.to_f
    end

    # This method is deprecated and will be removed in 3.0, as a node never
    # reaches 100% synchronization.
    #
    # @return [Boolean] signalling if this node ever reaches 100% synchronized
    def synced?
      warn "[DEPRECATION] `synced?` is deprecated and will be removed in 3.0"
      rpc(:block_count)[:unchecked] == 0
    end

    # @return [Hash{Symbol=>Integer|String}] version information for this node
    def version
      rpc(:version)
    end
    alias_method :info, :version

    private

    def rpc(action, params={})
      @rpc.call(action, params)
    end

  end
end
