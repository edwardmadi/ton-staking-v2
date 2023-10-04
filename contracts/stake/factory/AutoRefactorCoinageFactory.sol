// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { CoinageFactoryI } from "../interfaces/CoinageFactoryI.sol";
import { AutoRefactorCoinageProxy } from "../tokens/AutoRefactorCoinageProxy.sol";

interface IIAutoRefactorCoinage {
  function initialize (
      string memory name_,
      string memory symbol_,
      uint256 factor_
    ) external;
}


contract AutoRefactorCoinageFactory is CoinageFactoryI, Ownable {
  uint256 constant public RAY = 10 ** 27; // 1 RAY
  uint256 constant internal _DEFAULT_FACTOR = RAY;

  address public autoCoinageLogic;

  function setAutoCoinageLogic(address newLogic) external onlyOwner {
    autoCoinageLogic = newLogic;
  }

  function deploy() external override returns (address) {
    AutoRefactorCoinageProxy c = new AutoRefactorCoinageProxy();
    c.upgradeTo(autoCoinageLogic);
    c.addMinter(msg.sender);

    IIAutoRefactorCoinage(address(c)).initialize(
      "StakedWTON",
      "sWTON",
      _DEFAULT_FACTOR
    );

    c.renounceMinter();
    c.transferOwnership(msg.sender);

    return address(c);
  }
}
