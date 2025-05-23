// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract KOLZPlayerRegistry {
    struct Player {
        string username;
        uint256 points;
        string telegramId;
        string telegramName;
        string email;
        string x;
        uint256 lastCheckIn;
        uint256 consecutiveCheckIns;
        uint256[] checkInTimestamps;
    }

    mapping(address => Player) private players;
    address[] private playerAddresses;
    address public owner;

    event PlayerRegistered(address indexed player, string username);
    event PointsIncreased(address indexed player, uint256 newPoints);
    event PointsDecreased(address indexed player, uint256 newPoints);
    event PlayerCheckedIn(address indexed player, uint256 timestamp, uint256 consecutiveDays);

    constructor() {
        owner = msg.sender;
    }

    function register(
        string calldata username,
        string calldata telegramId,
        string calldata telegramName,
        string calldata email,
        string calldata x
    ) external {
        require(bytes(username).length > 0, "Username required");
        require(bytes(players[msg.sender].username).length == 0, "Already registered");

        players[msg.sender] = Player({
            username: username,
            points: 0,
            telegramId: telegramId,
            telegramName: telegramName,
            email: email,
            x: x,
            lastCheckIn: 0,
            consecutiveCheckIns: 0,
            checkInTimestamps: new uint256[](0)
        });

        playerAddresses.push(msg.sender);
        emit PlayerRegistered(msg.sender, username);
    }

    function increasePoints(address player, uint256 amount) external {
        require(msg.sender == owner, "Only owner can increase points");
        require(bytes(players[player].username).length != 0, "Player not registered");

        players[player].points += amount;
        emit PointsIncreased(player, players[player].points);
    }

    function decreasePoints(address player, uint256 amount) external {
        require(msg.sender == owner, "Only owner can decrease points");
        require(bytes(players[player].username).length != 0, "Player not registered");
        require(players[player].points >= amount, "Insufficient points");

        players[player].points -= amount;
        emit PointsDecreased(player, players[player].points);
    }

    function checkIn() external {
        require(bytes(players[msg.sender].username).length != 0, "Player not registered");

        Player storage player = players[msg.sender];
        uint256 currentTimestamp = block.timestamp;

        if (player.lastCheckIn != 0) {
            uint256 daysSinceLastCheckIn = (currentTimestamp - player.lastCheckIn) / 1 days;
            require(daysSinceLastCheckIn >= 1, "Already checked in today");

            if (daysSinceLastCheckIn == 1) {
                player.consecutiveCheckIns += 1;
            } else {
                player.consecutiveCheckIns = 1;
            }
        } else {
            player.consecutiveCheckIns = 1;
        }

        player.lastCheckIn = currentTimestamp;
        player.checkInTimestamps.push(currentTimestamp);

        emit PlayerCheckedIn(msg.sender, currentTimestamp, player.consecutiveCheckIns);
    }

    function checkInWithRegisterIfNeeded(
        string calldata username,
        string calldata telegramId,
        string calldata telegramName,
        string calldata email,
        string calldata x
        ) external {
            if (bytes(players[msg.sender].username).length == 0) {
                // New registration if player doesn't exists
                players[msg.sender] = Player({
                    username: username,
                    points: 0,
                    telegramId: telegramId,
                    telegramName: telegramName,
                    email: email,
                    x: x,
                    lastCheckIn: 0,
                    consecutiveCheckIns: 0,
                    checkInTimestamps: new uint256[](0)

                });
                playerAddresses.push(msg.sender);
                emit PlayerRegistered(msg.sender, username);
            }
        
            Player storage player = players[msg.sender];
            uint256 currentTimestamp = block.timestamp;
        
            if (player.lastCheckIn != 0) {
                uint256 daysSinceLastCheckIn = (currentTimestamp - player.lastCheckIn) / 1 days;
                require(daysSinceLastCheckIn >= 1, "Already checked in today");
        
                if (daysSinceLastCheckIn == 1) {
                    player.consecutiveCheckIns += 1;
                } else {
                    player.consecutiveCheckIns = 1;
                }
            } else {
                player.consecutiveCheckIns = 1;
            }
        
            player.lastCheckIn = currentTimestamp;
            player.checkInTimestamps.push(currentTimestamp);
        
            emit PlayerCheckedIn(msg.sender, currentTimestamp, player.consecutiveCheckIns);
    }

    function getProfile(address playerAddress) external view returns (
        string memory username,
        uint256 points,
        string memory telegramId,
        string memory telegramName,
        string memory email,
        string memory x,
        uint256 lastCheckIn,
        uint256 consecutiveCheckIns,
        uint256[] memory checkInTimestamps
    ) {
        Player storage p = players[playerAddress];
        return (
            p.username,
            p.points,
            p.telegramId,
            p.telegramName,
            p.email,
            p.x,
            p.lastCheckIn,
            p.consecutiveCheckIns,
            p.checkInTimestamps
        );
    }

    function isRegistered(address player) external view returns (bool) {
        return bytes(players[player].username).length > 0;
    }

    function getPlayersByCheckIn(uint256 minConsecutiveDays, uint256 targetDate) external view returns (address[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < playerAddresses.length; i++) {
            Player storage p = players[playerAddresses[i]];
            if (p.consecutiveCheckIns > minConsecutiveDays && isSameDay(p.lastCheckIn, targetDate)) {
                count++;
            }
        }

        address[] memory result = new address[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < playerAddresses.length; i++) {
            Player storage p = players[playerAddresses[i]];
            if (p.consecutiveCheckIns > minConsecutiveDays && isSameDay(p.lastCheckIn, targetDate)) {
                result[index] = playerAddresses[i];
                index++;
            }
        }

        return result;
    }

    function isSameDay(uint256 timestamp1, uint256 timestamp2) internal pure returns (bool) {
        return (timestamp1 / 1 days) == (timestamp2 / 1 days);
    }
}
