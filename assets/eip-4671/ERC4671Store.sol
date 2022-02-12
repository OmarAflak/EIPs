// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "./IERC4671Store.sol";

contract ERC4671Store is IERC4671Store, ERC165 {
    // Mapping from owner to IERC4671Enumerable contracts
    mapping(address => address[]) private _records;

    // Mapping from owner to IERC4671Enumerable contract index
    mapping(address => mapping(address => uint256)) _indices;

    /// @notice Add a IERC4671Enumerable contract address to the caller's record
    /// @param badge Address of the IERC4671Enumerable contract to add
    function add(address badge) public virtual override {
        address[] storage contracts = _records[msg.sender];
        _indices[msg.sender][badge] = contracts.length;
        contracts.push(badge);
        emit Added(msg.sender, badge);
    }

    /// @notice Remove a IERC4671Enumerable contract from the caller's record
    /// @param badge Address of the IERC4671Enumerable contract to remove
    function remove(address badge) public virtual override {
        uint256 index = _indexOfBadgeOrRevert(msg.sender, badge);
        address[] storage contracts = _records[msg.sender];
        if (index == contracts.length - 1) {
            _indices[msg.sender][badge] = 0;
        } else {
            _indices[msg.sender][contracts[contracts.length - 1]] = index;
        }
        contracts[index] = contracts[contracts.length - 1];
        contracts.pop();
        emit Removed(msg.sender, badge);
    }

    /// @notice Get all the IERC4671Enumerable contracts for a given owner
    /// @param owner Address for which to retrieve the IERC4671Enumerable contracts
    function get(address owner) public view virtual override returns (address[] memory) {
        return _records[owner];
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return 
            interfaceId == type(IERC4671Store).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _indexOfBadgeOrRevert(address owner, address badge) private view returns (uint256) {
        uint256 index = _indices[owner][badge];
        require(index > 0 || _records[owner].length > 0, "Address not found");
        return index;
    }
}
