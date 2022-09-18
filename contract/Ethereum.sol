// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.16;


//
contract ENS {
    event NewUser(string _username, address walletAddress);

    event Sent_Eth(address sender, address receiever, uint256 amount);

    // Mapping system that connects name to address
    mapping(string => address) user;

    // Mapping variable that find the name of an address
    mapping(address => string) public userAddressLink;

    // A variable to check if the address has a name based of the state of its boolen
    mapping(address => bool) public wallet_Address;

    /**
        @dev allows unregistered users to create a profile with a username
        @param _username username of user
     */
    function addUser(string calldata _username) public {
        require(bytes(_username).length > 0, "Empty username");
        require(
            wallet_Address[msg.sender] == false,
            "This user has already been registered"
        );
        // This check was put in place to prevent users from picking a username that is already in use
        require(
            user[_username] == address(0),
            "This username is already taken"
        );
        user[_username] = msg.sender;
        userAddressLink[msg.sender] = _username;
        wallet_Address[msg.sender] = true;
        emit NewUser(_username, msg.sender);
    }

    function getUserViaUsername(string calldata _username)
        public
        view
        returns (address)
    {
        return user[_username];
    }

    /**
     *  @dev allow users to transfer funds to another user by using their address
     * @param _username username of the user
     */
    function sendEth(string calldata _username) public payable {
        address receiverAddress = getUserViaUsername(_username);
        require(receiverAddress != address(0), "Query of nonexistent user");
        (bool sent, ) = payable(receiverAddress).call{value: msg.value}("");
        require(sent, "Failed Transaction");
        emit Sent_Eth(msg.sender, receiverAddress, msg.value);
    }
}
