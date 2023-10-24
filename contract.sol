// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Campaigns_Funding_Project {

    address public owner;

    struct Campaign {
        address creator;
        string cause;
        string futurePlans;
        uint256 startDate;
        uint256 endDate;
        uint256 goalAmount;
        uint256 totalFunds;
        bool isActive;
    }
    struct Funding {
        address funder;
        uint256 campaignId;
        uint256 amount;
    }
    
    Campaign[] public campaigns;
    Funding[] public fundings;
    
    event CampaignCreated(uint256 indexed campaignId, address indexed creator, string cause);
    event ProjectFunded(uint256 indexed fundingId, uint256 indexed campaignId, address indexed funder, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier campaignExists(uint256 _campaignId) {
        require(_campaignId < campaigns.length && campaigns[_campaignId].isActive, "Campaign does not exist or is not active");
        _;
    }


    constructor() {
        owner = msg.sender;
    }

    function createCampaign(
        string memory _cause,
        string memory _futurePlans,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _goalAmount
    ) external onlyOwner {
         //Checks if the campaign start date is before the end date.
        require(_startDate < _endDate, "Invalid campaign dates");

        Campaign memory newCampaign = Campaign({
            creator: msg.sender,
            cause: _cause,
            futurePlans: _futurePlans,
            startDate: _startDate,
            endDate: _endDate,
            goalAmount: _goalAmount,
            totalFunds: 0,
            isActive: true
        });
        campaigns.push(newCampaign);
        emit CampaignCreated(campaigns.length - 1, msg.sender, _cause);
    }


    function fundProject(uint256 _campaignId) external payable campaignExists(_campaignId) {
        Campaign storage campaign = campaigns[_campaignId];
        require(msg.value > 0, "Invalid fund amount");
        require(block.timestamp <= campaign.endDate, "Campaign has ended");
        require(campaign.totalFunds + msg.value <= campaign.goalAmount, "Goal amount reached");

        Funding memory newFunding = Funding({
            funder: msg.sender,
            campaignId: _campaignId,
            amount: msg.value
        });
        fundings.push(newFunding);
        
        campaign.totalFunds += msg.value;
        emit ProjectFunded(fundings.length - 1, _campaignId, msg.sender, msg.value);
    }

    function getAvailableProjects() external view returns (Campaign[] memory) {
        uint256 activeCampaignsCount = 0;
        for (uint256 i = 0; i < campaigns.length; i++) {
            if (campaigns[i].isActive && block.timestamp <= campaigns[i].endDate) {
                activeCampaignsCount++;
            }
        }

        Campaign[] memory activeCampaigns = new Campaign[](activeCampaignsCount);
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < campaigns.length; i++) {
            if (campaigns[i].isActive && block.timestamp <= campaigns[i].endDate) {
                activeCampaigns[currentIndex] = campaigns[i];
                currentIndex++;
            }
        }

        return activeCampaigns;
    }
}
