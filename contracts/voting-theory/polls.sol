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
        bytes32[] options;   // To track options
        uint32 endTime;
        mapping (bytes32 => uint256) votes;  // Option : Count
        mapping (address => bool) voted;    // Address : Voted?
    }

    // struct ActivePolls {
    //     string title;
    //     bytes32[] options;
    //     uint32 endTime;
    //     uint256 pollId;
    // }

    // Struct-array to store the polls created
    Poll[] public polls;
    // mapping (uint256 => bool) public activePolls;

    event PollCreated(string title, bytes32[] options, uint256 duration);
    event Voted(address voter, uint256 pollId);

    /// @dev To check whether the poll is active
    modifier onlyActive(uint256 _pollId) {
        require(block.timestamp < polls[_pollId].endTime, "Poll closed");
        _;
    }

    /// @dev A function to create the poll in DApp
    function createPoll(string memory _title, bytes32[] memory _options, uint32 _duration) external returns (uint256) {
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
    function vote(uint256 _pollId, bytes32 _option) external onlyActive(_pollId) {
        require (_pollId < polls.length, "Invalid Poll ID");   // this line is not reflecting in log or as error yet instead smth abt payable error
        Poll storage poll = polls[_pollId];
        require (!poll.voted[msg.sender], "Already voted");
        require (isValidOption(poll.options, _option), "Invalid option");
        poll.votes[_option]++;
        poll.voted[msg.sender] = true;
        // emit Voted(abi.encodePacked(msg.sender , " has voted."));
        emit Voted(msg.sender, _pollId);
    }

    /// @dev Afunction to validate the proposed voting option
    function isValidOption(bytes32[] memory _options, bytes32 _option) internal pure returns (bool) {
        for(uint i = 0; i < _options.length; i++) {
            if(_options[i] == _option) {
                return true;
            }
        }
        return false;
    }

    /// @dev Afunction to get poll details
    function getPoll(uint256 _pollId) external view returns(string memory, bytes32[] memory, uint32) {
        Poll storage poll = polls[_pollId];
        return (poll.title, poll.options, poll.endTime);
    }

    /// @dev A function to retrieve the votes
    function getResults(uint256 _pollId) external view returns (bytes32[] memory, uint256[] memory, bool) {
        Poll storage poll = polls[_pollId];
        uint256[] memory counts = new uint256[](poll.options.length);
        for(uint i = 0; i < poll.options.length; i++) {
            counts[i] = poll.votes[poll.options[i]];
        }
        return (poll.options, counts, poll.endTime > block.timestamp);
    }

    /// @dev A function to get total polls
    function getTotalPolls() external view returns (uint256) {
        return polls.length;
    }


    /// @dev A function to retrieve the active polls
    // function getActivePolls() external view returns (ActivePolls[] memory) {
    //     uint256 activeCount = 0;
    //     for (uint i = 0; i < polls.length; i++) {
    //         if (polls[i].endTime >= block.timestamp) {
    //             activeCount++;
    //         }
    //     }
    //     ActivePolls[] memory actPoll = new ActivePolls[](activeCount);
    //     uint256 index = 0;
    //     for(uint i = 0; i < polls.length; i++) {
    //         if (polls[i].endTime >= block.timestamp) {
    //             actPoll[index] = ActivePolls({
    //                 pollId: i,
    //                 title: polls[i].title,
    //                 endTime: polls[i].endTime,
    //                 options: polls[i].options
    //             });
    //             index++;
    //         }
    //     }
    //     return actPoll;
    // }

}