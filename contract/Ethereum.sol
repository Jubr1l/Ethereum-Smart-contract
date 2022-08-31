// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;


contract CNS{

    event NewUser(
        string _inputtedusername,
        address walletAddress
    );

    event Sent_Eth(
        address sender,
        address receiever
    );

    //address of the cusd token, i need this to interact with the cusd token
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    // Mapping system that connects name to address
    mapping (string=>address) user;

    // Mapping variable that find the name of an address
    mapping (address => string) public userAddressLink;

    // A variable to check if the address has a name based of the state of its boolen
    mapping(address => bool) public wallet_Address;

    // this check prevent users who wants to create more than one name with one address
    modifier CheckBooleanLink{
        require(
            wallet_Address[msg.sender] == false,
            "This user has already been registered"
        );
        _;
    }

    // This check was put in place to prevent users from picking a username that is already in use
    // Imagine waking up and your username belongs to someone else, it wouldnt be right.
    // This will check that there is no address assigned to the name you would like to use

    modifier UsernameAvailability(string memory _inputtedusername){
        address addressResult = user[_inputtedusername];
        require(addressResult ==  0x0000000000000000000000000000000000000000, "This username is already taken");
        _;
    } 

    function addUser(string memory _inputtedusername) public CheckBooleanLink UsernameAvailability(_inputtedusername){
        user[_inputtedusername] = msg.sender;
        userAddressLink[msg.sender] = _inputtedusername;
        wallet_Address[msg.sender] = true;
        emit NewUser(_inputtedusername, msg.sender);
    }

    function getUserViaUsername(string memory _inputtedusername) public view returns(address){
        return user[_inputtedusername];
    }


    // Check to see that the username is associated with an address that is not null
    modifier checkBeforeSend(string memory username){
        address theresult = user[username];
        require(theresult != 0x0000000000000000000000000000000000000000, "This user does not exist" );
        _;
    }

    function sendEth(string memory name) public checkBeforeSend(name) payable {
        address receiverAddress = getUserViaUsername(name);
        address payable _receiver = payable(receiverAddress);
        (bool sent, bytes memory data) = _receiver.call{value: msg.value}("");
        require(sent, "Failed Transaction");
        emit Sent_Eth(msg.sender,  receiverAddress);
    }


}
