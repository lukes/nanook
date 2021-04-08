# frozen_string_literal: true

require 'bigdecimal'

class Nanook
  # Set of utility methods.
  module Util
    # Constant used to convert back and forth between raw and NANO.
    STEP = BigDecimal('10')**BigDecimal('30')

    private

    # Converts an amount of NANO to an amount of raw.
    #
    # @param nano [Float|Integer] amount in nano
    # @return [Integer] amount in raw
    def NANO_to_raw(nano)
      return if nano.nil?

      (BigDecimal(nano.to_s) * STEP).to_i
    end

    # Converts an amount of raw to an amount of NANO.
    #
    # @param raw [Integer] amount in raw
    # @return [Float|Integer] amount in NANO
    def raw_to_NANO(raw)
      return if raw.nil?

      (raw.to_f / STEP).to_f
    end

    # @return [TrueClass] if unit is valid.
    # @raise [Nanook::NanoUnitError] if `unit` is invalid.
    def validate_unit!(unit)
      raise Nanook::NanoUnitError, "Unit #{unit} must be one of #{Nanook::UNITS}" unless Nanook::UNITS.include?(unit.to_sym)

      true
    end

    def as_account(account_id)
      Nanook::Account.new(@rpc, account_id)
    end

    def as_wallet_account(account_id)
      Nanook::WalletAccount.new(@rpc, @wallet, account_id)
    end

    def as_block(block_id)
      Nanook::Block.new(@rpc, block_id)
    end

    def as_private_key(key)
      Nanook::PrivateKey.new(@rpc, key)
    end

    def as_public_key(key)
      Nanook::PublicKey.new(@rpc, key)
    end
  end
end
