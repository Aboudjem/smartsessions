// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice 
/// @author 
///
/// @dev Note:
/// sdsd\

/*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
/*                          STRUCTS                           */
/*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

/// @dev An 
struct AddressArrayMap4337 {
    uint256 _spacer;
}

library ArrayMap4337Lib {

    using ArrayMap4337Lib for AddressArrayMap4337;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The index must be less than the length.
    error IndexOutOfBounds();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The storage layout is given by:
    /// ```
    ///     mstore(0x04, _ENUMERABLE_WORD_SET_SLOT_SEED)
    ///     mstore(0x00, set.slot)
    ///     let rootSlot := keccak256(0x00, 0x24)
    ///     mstore(0x20, rootSlot)
    ///     mstore(0x00, value)
    ///     let positionSlot := keccak256(0x00, 0x40)
    ///     let valueSlot := add(rootSlot, sload(positionSlot))
    ///     let valueInStorage := sload(valueSlot)
    ///     let lazyLength := sload(not(rootSlot))
    /// ```
    uint256 private constant _ARRAY_SLOT_SEED = 0x1d3b4864;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     GETTERS / SETTERS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function length(AddressArrayMap4337 storage s, address key) internal view returns (uint256 length) {
        assembly {
            mstore(0x00, key)
            mstore(0x20, s.slot)
            length := sload(keccak256(0x00, 0x40))
        }
    }

    function get(AddressArrayMap4337 storage s, address key, uint256 index) internal view returns (address value) {
        //bytes32 rootSlot = _rootSlot(s);
        assembly {
            mstore(0x00, key)
            mstore(0x20, s.slot)
            value := sload(add(keccak256(0x00, 0x40), mul(0x20, add(index, 1))))
        }
    }

    function contains(AddressArrayMap4337 storage s, address key, address element) internal view returns (bool) {
        uint256 length = s.length(key);
        for(uint256 i; i<length; i++) {
            if(s.get(key, i) == element) {
                return true;
            } 
        }
        return false;
    }

    function push(AddressArrayMap4337 storage s, address key, address element) internal {
        assembly {
            mstore(0x00, key) // store a
            mstore(0x20, s.slot)  //store x
            let slot := keccak256(0x00, 0x40)
            // load length (stored @ slot), add 1 to it => index. 
            // mul index by 0x20 and add it to orig slot to get the next free slot
            let index := add(sload(slot), 1)
            sstore(add(slot, mul(0x20, index)), element)
            sstore(slot, index) //increment length by 1
        }
    }

    function remove (AddressArrayMap4337 storage s, address key, address element) internal returns (uint256) {
        uint256 length = s.length(key);
        for(uint256 i; i<length; i++) {
            if(s.get(key, i) == element) {
                // TODO: get last element and record it to i's position   
                // TODO: pop last element    
                return i;
            } 
        }
        revert();
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      PRIVATE HELPERS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the root slot.
    function _rootSlot(AddressArrayMap4337 storage s) private pure returns (bytes32 r) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x04, _ARRAY_SLOT_SEED)
            mstore(0x00, s.slot)
            r := keccak256(0x00, 0x24)
        }
    }
}
