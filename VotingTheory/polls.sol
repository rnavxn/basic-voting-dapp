// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract Polls {
    // Structure of poll
    struct Poll {
        string title;
        uint32 startTime;
        uint32 endTime;
        uint64 duration;
        address creator;
        mapping (string => uint256) votes;
        mapping (address => bool) is_voted;
    }

    // Struct-array to store the polls created
    Poll[] private polls;

    event PollCreated(string title, string[], uint endTime);

    // To check whether the poll is active
    modifier onlyActive(uint256 _pollId) {
        require(block.timestamp < polls[_pollId].endTime, "Poll closed");
        _;
    }

    // @dev: A function to create the poll in DApp
    function createPoll(string memory _title, uint32 _startTime, uint32 _endTime, string[] memory _options) public returns (uint64) {
        polls.push();
        uint256 pollId = polls.length - 1;
        polls[pollId].title = _title;
        polls[pollId].startTime = _startTime;
        polls[pollId].endTime = _endTime;
        polls[pollId].duration = uint64(_endTime - _startTime);
        polls[pollId].creator = msg.sender;
        for(uint i = 0; i < _options.length; i++) {
            polls[pollId].votes[_options[i]] = 0;
        }
        emit PollCreated(_title, _options , _endTime);
        return uint64(pollId);
    }

    // @dev: A function to get active polls in the DApp
    function getActivePolls(uint256 _pollId) public onlyActive(_pollId) view returns (string memory, uint32, uint32, uint64, address) {
        return (polls[_pollId].title, polls[_pollId].startTime, polls[_pollId].endTime, polls[_pollId].duration, polls[_pollId].creator);
    }

    // @dev: 
    function getVoteCount(uint256 _pollId, string memory _option) public view returns (uint256) {
        return polls[_pollId].votes[_option]; // Returns vote count for an option
    }
    
    function vote(uint256 _pollId, string memory _option) public {
        polls[_pollId].votes[_option]++;
    }
}