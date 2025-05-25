// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/// @title A contract for managing polls
/// @author Navin Rajmohan
/// @notice You can use this contract for only the most basic voting
/// @dev All function calls are currently implemented without side effects
/// @custom:experimental This is an experimental contract.

contract Polls {
    // Structure of poll
    struct Poll {
        string title;
        string[] options;   // To track options
        uint32 endTime;
        mapping (string => uint256) votes;  // Option : Count
        mapping (address => bool) voted;    // Address : Voted?
    }

    // Struct-array to store the polls created
    Poll[] private polls;
    // Poll[] private activePolls;

    event PollCreated(string title, string[] options, uint256 duration);
    event Voted(bytes);

    /// @dev To check whether the poll is active
    modifier onlyActive(uint256 _pollId) {
        require(block.timestamp < polls[_pollId].endTime, "Poll closed");
        _;
    }

    /// @dev A function to create the poll in DApp
    function createPoll(string memory _title, string[] memory _options, uint32 _duration) public returns (uint256) {
        require (_options.length > 0, "No options provided");
        polls.push();
        uint256 pollId = polls.length - 1;
        Poll storage poll = polls[pollId];
        poll.title = _title;
        poll.options =  _options;
        poll.endTime = uint32(block.timestamp) + _duration;
        // Emit the event
        emit PollCreated(_title, _options, _duration);
        return pollId;
    }

    /// @dev A fucntion to make the vote
    function vote(uint256 _pollId, string memory _option) public onlyActive(_pollId) {
        require (_pollId <= polls.length, "Invalid Poll ID");   // this line is not reflecting in log or as error yet instead smth abt payable error
        Poll storage poll = polls[_pollId];
        require (!poll.voted[msg.sender], "Already voted");
        require (isValidOption(poll.options, _option), "Invalid option");
        poll.votes[_option]++;
        poll.voted[msg.sender] = true;
        emit Voted(abi.encodePacked(msg.sender , " has voted."));
    }

    /// @dev Afunction to validate the proposed voting option
    function isValidOption(string[] memory _options, string memory _option) private pure returns (bool) {
        bytes32 optionHash = keccak256(bytes(_option));
        for(uint i = 0; i < _options.length; i++) {
            if(keccak256(bytes(_options[i])) == optionHash) {
                return true;
            }
        }
        return false;
    }

    /// @dev A function to retrieve the votes
    function getResults(uint256 _pollId) external view returns (string[] memory, uint256[] memory) {
        Poll storage poll = polls[_pollId];
        uint256[] memory counts = new uint256[](poll.options.length);
        for(uint i = 0; i < poll.options.length; i++) {
            counts[i] = poll.votes[poll.options[i]];
        }
        return (poll.options, counts);
    }
}