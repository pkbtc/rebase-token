// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract RebaseToken is ERC20,Ownable,AccessControl{
        error RebaseToken_InterestRateCanOnlyDecrease(uint256 s_interestRate,uint256 _newInterestRate);
        uint256 private s_interestRate=5e10;
        bytes32 private constant MINT_AND_BURN_ROLE=keccak256("MINT_AND_BURN_ROLE");
        uint256 private constant PRESSION_FACTOR=1e18;
        mapping(address=>uint256) private s_userInterestRate;
        mapping(address=>uint256) private s_userLastUpdatedTimestmap;
        event InterestRateSet(uint256 newInterestRate);

        constructor() ERC20 (
            "Rebase Token",
            "RBT"
        ) Ownable(msg.sender){

        }
        function grantMintAndBurnRole(address _account) external onlyOwner(){
            _grantRole(MINT_AND_BURN_ROLE, _account);
        }
        function setInterestRate(uint256 _newInterestRate) external onlyOwner(){
            if(_newInterestRate>s_interestRate){
                revert RebaseToken_InterestRateCanOnlyDecrease(s_interestRate,_newInterestRate);
            }
            s_interestRate=_newInterestRate;
            emit InterestRateSet(_newInterestRate);
        }
        function balanceOf(address _user) public view override returns(uint256){
            return super.balanceOf(_user)*__calculateUserAccumulatedInterestRateSinceLastUpdated(_user)/PRESSION_FACTOR;

        }
        function __calculateUserAccumulatedInterestRateSinceLastUpdated(address _user) internal view returns(uint256 linearInterest){
            uint256 timeElapsed=block.timestamp-s_userLastUpdatedTimestmap[_user];
            linearInterest=PRESSION_FACTOR+(s_userInterestRate[_user]*timeElapsed);
        }
        function mint(address _to,uint256 _value,uint256 _userInterestRate) internal onlyRole(MINT_AND_BURN_ROLE){
            _mintAccurateInterest(_to);
            s_userInterestRate[_to]=_userInterestRate;
            _mint(_to,_value); 
        }
        function burn(address _from,uint256 _amount) external onlyRole(MINT_AND_BURN_ROLE){
            if(_amount==type(uint256).max){
                _burn(_from,balanceOf(_from));
            }
            _mintAccurateInterest(_from);
            _burn(_from,_amount);
        }
        function transfer(address _recipient,uint256 _amount) public override returns(bool){
            _mintAccurateInterest(msg.sender);
            _mintAccurateInterest(_recipient);
            if(_amount==type(uint256).max){
                _amount=balanceOf(msg.sender);
            }
            if(balanceOf(_recipient)==0){
                s_userInterestRate[_recipient]=s_userInterestRate[msg.sender];
            }
            return super.transfer(_recipient,_amount);
        }
        function transferFrom(address _sender,address _recipient,uint256 _amount) public override returns(bool){
            _mintAccurateInterest(_sender);
            _mintAccurateInterest(_recipient);
            if(_amount==type(uint256).max){
                _amount=balanceOf(_sender);
            }
            if(balanceOf(_recipient)==0){
                s_userInterestRate[_recipient]=s_userInterestRate[_sender];
            }
            return super.transferFrom(_sender,_recipient,_amount);
        }
        function principalBalance(address _user) public view returns(uint256){
            return super.balanceOf(_user);
        }
        function getInterestRate() external view returns(uint256){
            return s_interestRate;
        }
        function _mintAccurateInterest(address _user) private{
            uint256 preciousPrinciaplBalance=super.balanceOf(_user);
            uint256 currentBalance=balanceOf(_user);
            uint256 balanceIncrease=currentBalance-preciousPrinciaplBalance;
            _mint(_user,balanceIncrease);
            s_userLastUpdatedTimestmap[_user]=block.timestamp;
        }
        function getUserInrestRate(address _user) external view returns(uint256){
            return s_userInterestRate[_user];
        }

}