// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "erc721a/ERC721A.sol";
import "operator-filter-registry/UpdatableOperatorFilterer.sol";
import "openzeppelin-contracts/access/Ownable.sol";
import "solmate/utils/ReentrancyGuard.sol";

// import "solmate/utils/MerkleProofLib.sol";

error TokenDoesNotExist();

contract GigaCityStreets is UpdatableOperatorFilterer(
        0x0000000000000000000000000000000000000000,
        0x0000000000000000000000000000000000000000,
        false
    ), ERC721A, Ownable {

    string public uriPrefix = "https://server.com/";
    string public uriSuffix = ".json";

    // Corpo merkle root
    // bytes32 private _whitelistRoot;

    uint256 public cost;
    uint256 public maxSupply;
    uint256 public maxMintAmountPerTx;

    // =============================================================
    //                           CONSTRUCTOR
    // =============================================================

    constructor() ERC721A("Giga City Streets", "GCS") {
        cost = 0;
        maxSupply = 1337;
        maxMintAmountPerTx = 1;
    }

    // =============================================================
    //                             MINT
    // =============================================================

    function mint(uint256 quantity) external payable {
        // (bytes32[] calldata proof_, uint256 quantity_)

        // require(!paused, 'The minting is paused!');
        // require(quantity > 0 && quantity <= maxMintAmountPerTx, 'Invalid mint amount!');
        // require(totalSupply() + quantity <= maxSupply, 'Max supply exceeded!');
        // require(msg.value >= cost * quantity, 'Insufficient funds!');

        // bytes32 leaf = keccak256(abi.encodePacked(_msgSenderERC721A()));
        // if (!MerkleProofLib.verify(proof_, _corpoRoot, leaf)) revert CantMintCorpo();

        _safeMint(msg.sender, quantity);
    }

    // =============================================================
    //                           MANAGEMENT
    // =============================================================

    function setUriPrefix(uint256 uriPrefix_) external{
        uriPrefix = uriPrefix_;
    }

    function setUriSuffix(uint256 uriSuffix_) external{
        uriSuffix = uriSuffix_;
    }

    function setCost(uint256 cost_) external{
        cost = cost_;
    }

    function setMaxSupply(uint256 maxSupply_) external{
        maxSupply = maxSupply_;
    }

    function setMaxMintAmountPerTx(uint256 maxMintAmountPerTx_) external{
        maxMintAmountPerTx = maxMintAmountPerTx_;
    }

    function setCorpoRoot(bytes32 newRoot_) external onlyOwner {
        _whitelistRoot = newRoot_;
    }

    // =============================================================
    //                           OWNABLE
    // =============================================================

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual override(UpdatableOperatorFilterer, Ownable) returns (address) {
        return super.owner();
    }

    // =============================================================
    //                           METADATA
    // =============================================================

    function _baseURI() internal view virtual override returns (string memory) {
        return uriPrefix;
    }

    function tokenURI(uint256 _tokenId) public view virtual override(ERC721A) returns (string memory) {
        if (!_exists(_tokenId)) revert TokenDoesNotExist();

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, _toString(_tokenId), uriSuffix))
            : '';
    }

    // =============================================================
    //                           WITHDRAW
    // =============================================================

    function withdraw() external onlyOwner nonReentrant() {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        if (!success) revert TransferFailed();
    }
}