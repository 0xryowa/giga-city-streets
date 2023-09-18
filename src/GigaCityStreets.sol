// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "erc721a/ERC721A.sol";
import "operator-filter-registry/UpdatableOperatorFilterer.sol";
import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/security/ReentrancyGuard.sol";

// =============================================================
//
//   ▄████  ██▓  ▄████  ▄▄▄       ▄████▄   ██▓▄▄▄█████▓▓██   ██▓
//  ██▒ ▀█▒▓██▒ ██▒ ▀█▒▒████▄    ▒██▀ ▀█  ▓██▒▓  ██▒ ▓▒ ▒██  ██▒
// ▒██░▄▄▄░▒██▒▒██░▄▄▄░▒██  ▀█▄  ▒▓█    ▄ ▒██▒▒ ▓██░ ▒░  ▒██ ██░
// ░▓█  ██▓░██░░▓█  ██▓░██▄▄▄▄██ ▒▓▓▄ ▄██▒░██░░ ▓██▓ ░   ░ ▐██▓░
// ░▒▓███▀▒░██░░▒▓███▀▒ ▓█   ▓██▒▒ ▓███▀ ░░██░  ▒██▒ ░   ░ ██▒▓░
//  ░▒   ▒ ░▓   ░▒   ▒  ▒▒   ▓▒█░░ ░▒ ▒  ░░▓    ▒ ░░      ██▒▒▒ 
//   ░   ░  ▒ ░  ░   ░   ▒   ▒▒ ░  ░  ▒    ▒ ░    ░     ▓██ ░▒░ 
// ░ ░   ░  ▒ ░░ ░   ░   ░   ▒   ░         ▒ ░  ░       ▒ ▒ ░░  
//       ░  ░        ░       ░  ░░ ░       ░            ░ ░     
//                              ░                      ░ ░     
//
// Venture into Giga City's towering shadows, where resilience
// is the only currency of survival.

// =============================================================
//                             ERRORS
// =============================================================

error TokenDoesNotExist();
error TransferFailed();
error TotalSupplyExceeded();
error PublicMintOff();
error TxQuantityExceeded();
error AddressQuantityExceeded();

// =============================================================
//                       GIGA CITY STREETS
// =============================================================

contract GigaCityStreets is ERC721A, UpdatableOperatorFilterer, ReentrancyGuard, Ownable {

    // Not mintable for public, most likely. I might open it up eventually,
    // if there will be damnd. Keeping it closed for now.
    bool public mintOpen;
    
    // Lets initialize the value for 0, paying / tipping will be optional
    uint256 public mintPrice;

    // Limit will be 1337, but added a setter that can change
    // this value at any time.
    uint256 public supplyCap;

    // Where is the metadata hosted
    string private _uriPrefix;

    // For now, we will initialize it with .json but might not be needed
    // when/if we transition on a server
    string private _uriSuffix;

    // Minting is limited to X per Tx. 
    uint256 private _maxMintPerTx;

    // Minting is limited to X per addy.
    uint256 private _maxMintPerAddress;

    // Mapping whitelist allocation
    mapping(address => uint256) private _mintAllocation;

    // =============================================================
    //                           CONSTRUCTOR
    // =============================================================

    constructor(address operatorFilterRegistry_)
        ERC721A("Giga City Streets", "GCS")
        UpdatableOperatorFilterer(operatorFilterRegistry_,0x0000000000000000000000000000000000000000,false) {
        mintOpen = false;
        mintPrice = 0;
        supplyCap = 1337;

        _maxMintPerTx = 1;
        _maxMintPerAddress = 1;

        _uriSuffix = '.json';
    }

    // =============================================================
    //                             MINT
    // =============================================================


    modifier mintable(uint256 quantity_) {
        // Are we exceeding the supply cap? If yeah revert.
        if (totalSupply() + quantity_ > supplyCap) revert TotalSupplyExceeded();
        // Are we minting above transaction limit? If yeah revert.
        if (quantity_ < 0 || quantity_ > _maxMintPerTx) revert TxQuantityExceeded();
        // Are we minting more than what is the maximum mint per address? If yeah revert.
        if (_numberMinted(msg.sender) == _maxMintPerAddress || _numberMinted(msg.sender) + quantity_ > _maxMintPerAddress ) revert AddressQuantityExceeded();
        // We proceed ...
        _;
    }


    function mintPublic(uint256 quantity_) external payable mintable(quantity_) {
        // Are we exceeding the supply cap? If yeah revert.
        if (!mintOpen) revert PublicMintOff();

        // require(!paused, 'The minting is paused!');
        // require(quantity > 0 && quantity <= maxMintAmountPerTx, 'Invalid mint amount!');
        // require(totalSupply() + quantity <= maxSupply, 'Max supply exceeded!');
        // require(msg.value >= cost * quantity, 'Insufficient funds!');

        // bytes32 leaf = keccak256(abi.encodePacked(_msgSenderERC721A()));
        // if (!MerkleProofLib.verify(proof_, _corpoRoot, leaf)) revert CantMintCorpo();

        _safeMint(msg.sender, quantity_);
    }

    // =============================================================
    //                            WHITELIST
    // =============================================================

    function setWhitelist(address wlAddress_, uint256 wlAllocation_) external{
        _mintAllocation[wlAddress_] = wlAllocation_;
    }

    // =============================================================
    //                           MANAGEMENT
    // =============================================================

    function setMintOpen(bool mintOpen_) external {
        mintOpen = mintOpen_;
    }

    function setUriPrefix(string calldata uriPrefix_) external{
        _uriPrefix = uriPrefix_;
    }

    function setUriSuffix(string calldata uriSuffix_) external{
        _uriSuffix = uriSuffix_;
    }

    function setMintPrice(uint256 mintPrice_) external{
        mintPrice = mintPrice_;
    }

    function setSupplyCap(uint256 supplyCap_) external{
        supplyCap = supplyCap_;
    }

    function setMaxMintPerTx(uint256 maxMintPerTx_) external{
        _maxMintPerTx = maxMintPerTx_;
    }

    function setMaxMintPerAddress(uint256 maxMintPerAddress_) external{
        _maxMintPerAddress = maxMintPerAddress_;
    }

    // =============================================================
    //                           OWNABLE
    // =============================================================

    function owner() public view virtual override(UpdatableOperatorFilterer, Ownable) returns (address) {
        return super.owner();
    }

    // =============================================================
    //                           METADATA
    // =============================================================

    function _baseURI() internal view virtual override returns (string memory) {
        return _uriPrefix;
    }

    function tokenURI(uint256 _tokenId) public view virtual override(ERC721A) returns (string memory) {
        if (!_exists(_tokenId)) revert TokenDoesNotExist();

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, _toString(_tokenId), _uriSuffix))
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