// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract CharityDonationPlatform {
    struct CharityProject {
        uint256 id;
        string name;
        string description;
        string category;
        uint256 targetAmount;
        uint256 raisedAmount;
        address payable beneficiary;
        bool isActive;
        uint256 createdAt;
    }

    struct Donation {
        uint256 projectId;
        uint256 amount;
        address donor;
        uint256 timestamp;
        bool isAnonymous;
    }

    mapping(uint256 => CharityProject) public charityProjects;
    mapping(uint256 => Donation[]) public projectDonations;
    mapping(address => uint256[]) public userDonations;
    
    uint256 public nextProjectId = 1;
    uint256 public totalProjects = 0;
    uint256 public totalDonations = 0;
    
    event ProjectCreated(uint256 indexed projectId, string name, uint256 targetAmount);
    event DonationMade(uint256 indexed projectId, uint256 amount, uint256 timestamp);
    event AnonymousDonationMade(uint256 indexed projectId, uint256 amount, uint256 timestamp);
    event FundsWithdrawn(uint256 indexed projectId, uint256 amount);

    modifier onlyActiveProject(uint256 projectId) {
        require(charityProjects[projectId].isActive, "Project is not active");
        _;
    }

    function createProject(
        string memory _name,
        string memory _description,
        string memory _category,
        uint256 _targetAmount,
        address payable _beneficiary
    ) external {
        require(_targetAmount > 0, "Target amount must be greater than 0");
        require(_beneficiary != address(0), "Invalid beneficiary address");

        charityProjects[nextProjectId] = CharityProject({
            id: nextProjectId,
            name: _name,
            description: _description,
            category: _category,
            targetAmount: _targetAmount,
            raisedAmount: 0,
            beneficiary: _beneficiary,
            isActive: true,
            createdAt: block.timestamp
        });

        emit ProjectCreated(nextProjectId, _name, _targetAmount);
        
        totalProjects++;
        nextProjectId++;
    }

    function makeDonation(uint256 _projectId, bool _isAnonymous) 
        external 
        payable 
        onlyActiveProject(_projectId) 
    {
        require(msg.value > 0, "Donation amount must be greater than 0");

        // Store donation
        Donation memory donation = Donation({
            projectId: _projectId,
            amount: msg.value,
            donor: _isAnonymous ? address(0) : msg.sender,
            timestamp: block.timestamp,
            isAnonymous: _isAnonymous
        });

        projectDonations[_projectId].push(donation);
        if (!_isAnonymous) {
            userDonations[msg.sender].push(_projectId);
        }

        // Update project raised amount
        charityProjects[_projectId].raisedAmount += msg.value;

        if (_isAnonymous) {
            emit AnonymousDonationMade(_projectId, msg.value, block.timestamp);
        } else {
            emit DonationMade(_projectId, msg.value, block.timestamp);
        }
        
        totalDonations++;
    }


    function withdrawFunds(uint256 _projectId, uint256 _amount) 
        external 
        onlyActiveProject(_projectId) 
    {
        CharityProject storage project = charityProjects[_projectId];
        require(msg.sender == project.beneficiary, "Only beneficiary can withdraw");
        require(_amount <= project.raisedAmount, "Insufficient funds");
        require(address(this).balance >= _amount, "Contract insufficient balance");

        project.raisedAmount -= _amount;
        project.beneficiary.transfer(_amount);

        emit FundsWithdrawn(_projectId, _amount);
    }

    function closeProject(uint256 _projectId) external {
        CharityProject storage project = charityProjects[_projectId];
        require(msg.sender == project.beneficiary, "Only beneficiary can close project");
        require(project.isActive, "Project already closed");

        project.isActive = false;
    }

    function getProject(uint256 _projectId) external view returns (CharityProject memory) {
        return charityProjects[_projectId];
    }

    function getAllProjects() external view returns (CharityProject[] memory) {
        CharityProject[] memory projects = new CharityProject[](totalProjects);
        uint256 index = 0;
        
        for (uint256 i = 1; i < nextProjectId; i++) {
            if (charityProjects[i].id != 0) {
                projects[index] = charityProjects[i];
                index++;
            }
        }
        
        return projects;
    }

    function getActiveProjects() external view returns (CharityProject[] memory) {
        uint256 activeCount = 0;
        
        // Count active projects
        for (uint256 i = 1; i < nextProjectId; i++) {
            if (charityProjects[i].isActive) {
                activeCount++;
            }
        }
        
        CharityProject[] memory activeProjects = new CharityProject[](activeCount);
        uint256 index = 0;
        
        for (uint256 i = 1; i < nextProjectId; i++) {
            if (charityProjects[i].isActive) {
                activeProjects[index] = charityProjects[i];
                index++;
            }
        }
        
        return activeProjects;
    }

    function getProjectDonations(uint256 _projectId) 
        external 
        view 
        returns (uint256[] memory, uint256[] memory, address[] memory, bool[] memory) 
    {
        Donation[] memory donations = projectDonations[_projectId];
        uint256[] memory timestamps = new uint256[](donations.length);
        uint256[] memory amounts = new uint256[](donations.length);
        address[] memory donors = new address[](donations.length);
        bool[] memory isAnonymous = new bool[](donations.length);
        
        for (uint256 i = 0; i < donations.length; i++) {
            timestamps[i] = donations[i].timestamp;
            amounts[i] = donations[i].amount;
            donors[i] = donations[i].donor; // Will be address(0) for anonymous donations
            isAnonymous[i] = donations[i].isAnonymous;
        }
        
        return (timestamps, amounts, donors, isAnonymous);
    }

    function getUserDonationCount(address _user) external view returns (uint256) {
        return userDonations[_user].length;
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Emergency functions
    function pause() external {
        // Implementation for emergency pause
    }

    function unpause() external {
        // Implementation for unpause
    }

    receive() external payable {}
    fallback() external payable {}
}