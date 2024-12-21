
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LearnToEarn {
    struct Contest {
        uint256 id;
        string title;
        string description;
        address[] participants;
        address winner;
        uint256 prizePool;
        bool isActive;
    }

    mapping(uint256 => Contest) public contests;
    mapping(uint256 => mapping(address => string)) public submissions; // Nested mapping for submissions
    uint256 public contestCount;
    mapping(address => uint256) public rewards;

    event ContestCreated(uint256 contestId, string title);
    event MemeSubmitted(uint256 contestId, address participant, string memeUrl);
    event ContestEnded(uint256 contestId, address winner, uint256 prize);

    function createContest(string memory _title, string memory _description) public {
        contestCount++;
        contests[contestCount] = Contest(contestCount, _title, _description, new address[](0), address(0), 0, true);
        emit ContestCreated(contestCount, _title);
    }

    function submitMeme(uint256 _contestId, string memory _memeUrl) public {
        require(contests[_contestId].isActive, "Contest is not active");
        contests[_contestId].participants.push(msg.sender);
        submissions[_contestId][msg.sender] = _memeUrl; // Store submission in the nested mapping
        emit MemeSubmitted(_contestId, msg.sender, _memeUrl);
    }

    function endContest(uint256 _contestId, address _winner) public {
        require(contests[_contestId].isActive, "Contest is not active");
        contests[_contestId].isActive = false;
        contests[_contestId].winner = _winner;
        uint256 prize = contests[_contestId].prizePool;
        rewards[_winner] += prize;
        emit ContestEnded(_contestId, _winner, prize);
    }

    function fundContest(uint256 _contestId) public payable {
        require(contests[_contestId].isActive, "Contest is not active");
        contests[_contestId].prizePool += msg.value;
    }

    function withdrawRewards() public {
        uint256 reward = rewards[msg.sender];
        require(reward > 0, "No rewards to withdraw");
        rewards[msg.sender] = 0;
        payable(msg.sender).transfer(reward);
    }
}