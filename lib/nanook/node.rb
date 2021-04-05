# frozen_string_literal: true

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
    alias frontier_count account_count

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

    # Initialize bootstrap to a specific IP address and port.
    #
    # @return [Boolean] indicating if the action was successful
    def bootstrap(address:, port:)
      rpc(:bootstrap, address: address, port: port).key?(:success)
    end

    # Initialize multi-connection bootstrap to random peers
    #
    # @return [Boolean] indicating if the action was successful
    def bootstrap_any
      rpc(:bootstrap_any).key?(:success)
    end

    # Initialize lazy bootstrap with given block hash
    #
    # @param hash [String]
    # @param force [Boolean] False by default. Manually force closing
    #   of all current bootstraps
    # @return [Boolean] indicating if the action was successful
    def bootstrap_lazy(hash, force: false)
      rpc(:bootstrap_lazy, hash: hash, force: force)[:started] == 1
    end

    # Returning status of current bootstrap attempt for debug purposes only.
    # This call is for internal diagnostics/debug purposes only.
    # Do not rely on this interface being stable and do not use in a
    # production system.
    #
    # ==== Example:
    #
    #   node.bootstrap_status
    #
    # Example response:
    #
    #   {
    #     clients: 5790,
    #     pulls: 141065,
    #     pulling: 3,
    #     connections: 16,
    #     idle: 0,
    #     target_connections: 64,
    #     total_blocks: 536820,
    #     lazy_mode: true,
    #     lazy_blocks: 423388,
    #     lazy_state_unknown: 2,
    #     lazy_balances: 0,
    #     lazy_pulls: 0,
    #     lazy_stopped: 644,
    #     lazy_keys: 449,
    #     lazy_key_1: "A86EB2B479AAF3CD531C8356A1FBE3CB500DFBF5BF292E5E6B8D1048DE199C32"
    #   }
    #
    # @return [Hash{Symbol=>String|Integer|Boolean}]
    def bootstrap_status
      rpc(:bootstrap_status)
    end

    # This call is for internal diagnostics/debug purposes only.
    # Do not rely on this interface being stable and do not use in a
    # production system.
    #
    # Returns block and tally weight (in raw) election duration (in
    # milliseconds), election confirmation timestamp for recent elections
    # winners.
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
    #       tally: 80394786589602980996311817874549318248,
    #       duration: 4000,
    #       time: 1544819986,
    #     },
    #     {
    #       block: "F2F8DA6D2CA0A4D78EB043A7A29E12BDE5B4CE7DE1B99A93A5210428EE5B8667",
    #       tally: 68921714529890443063672782079965877749,
    #       duration: 6000,
    #       time: 1544819988,
    #     }
    #   ]
    #
    # @return [Hash{Symbol=>String|Integer}]
    def confirmation_history
      rpc(:confirmation_history)[:confirmations].map do |history|
        # Rename hash key to block
        block = history.delete(:hash)
        { block: block }.merge(history)
      end
    end

    # Returns the difficulty values (16 hexadecimal digits string, 64 bit)
    # for the minimum required on the network (network_minimum) as well
    # as the current active difficulty seen on the network (network_current,
    # 5 minute trended average of adjusted difficulty seen on confirmed
    # transactions) which can be used to perform rework for better
    # prioritization of transaction processing. A multiplier of the
    # network_current from the base difficulty of network_minimum is also
    # provided for comparison.
    #
    # ==== Example:
    #
    #   node.difficulty(include_trend: true)
    #
    # Example response:
    #
    #   {
    #     network_minimum: "ffffffc000000000",
    #     network_current: "ffffffc1816766f2",
    #     multiplier: 1.024089858417128,
    #     difficulty_trend: [
    #       1.156096135149775,
    #       1.190133894573061,
    #       1.135567138563921,
    #       1.000000000000000,
    #     ]
    #   }
    #
    # @param include_trend [Boolean] false by default. Also returns the
    #   trend of difficulty seen on the network as a list of multipliers.
    #   Sampling occurs every 16 to 36 seconds. The list is ordered such
    #   that the first value is the most recent sample.
    # @return [Hash{Symbol=>String|Float|Array}]
    def difficulty(include_trend: false)
      rpc(:active_difficulty, include_trend: include_trend).tap do |response|
        response[:multiplier] = response[:multiplier].to_f

        response[:difficulty_trend].map!(&:to_f) if response.key?(:difficulty_trend)
      end
    end

    # @return [String]
    def inspect
      "#{self.class.name}(object_id: \"#{format('0x00%x', (object_id << 1))}\")"
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
    #     nano_1111111111111111111111111111111111111111111111111117353trpda: 3822372327060170000000000000000000000,
    #     nano_1111111111111111111111111111111111111111111111111awsq94gtecn: 30999999999999999999999999000000,
    #     nano_114nk4rwjctu6n6tr6g6ps61g1w3hdpjxfas4xj1tq6i8jyomc5d858xr1xi: 0
    #   }
    #
    # @return [Hash{Symbol=>Integer}] known representatives and their voting weight
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def representatives(unit: Nanook.default_unit)
      Nanook.validate_unit!(unit)

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
    #   node.representatives_online # => ["nano_111...", "nano_222"]
    #
    # @return [Array<String>] array of representative account ids
    def representatives_online
      rpc(:representatives_online)[:representatives].keys.map(&:to_s)
    end

    # Safely shuts down the node.
    #
    # @return [Boolean] indicating if action was successful
    def stop
      rpc(:stop).key?(:success)
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
    alias unchecked synchronizing_blocks

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
      total = count + unchecked

      count.to_f * 100 / total.to_f
    end

    # Returns node uptime in seconds
    #
    # @return [Integer] seconds of uptime
    def uptime
      rpc(:uptime)['seconds']
    end

    # This method is deprecated and will be removed in 3.0, as a node never
    # reaches 100% synchronization.
    #
    # @return [Boolean] signalling if this node ever reaches 100% synchronized
    def synced?
      warn '[DEPRECATION] `synced?` is deprecated and will be removed in 3.0'
      (rpc(:block_count)[:unchecked]).zero?
    end

    # @return [Hash{Symbol=>Integer|String}] version information for this node
    def version
      rpc(:version)
    end
    alias info version

    private

    def rpc(action, params = {})
      @rpc.call(action, params)
    end
  end
end
