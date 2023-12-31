# campaignscontract
# PROJECT II - CREATING A SMART CONTRACT

Explanation of each and every step is provided with the solidity code below.

```
// SPDX-License-Identifier: MIT
//This line specifies the version of Solidity that the contract code is compatible with.
pragma solidity ^0.8.0;
//This line defines the start of the contract named Campaigns_Funding_Project
contract Campaigns_Funding_Project {

    address public owner;
//Declares a state variable owner of type address that will store the address of the contract owner. The public keyword automatically generates a getter function for this variable.

// Defines a struct Campaign to store details of each campaign, including creator, cause, start and end dates, funding goal, total funds raised, and the active status.

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
//Defines another struct Funding to store funding details, including the funder's address, campaign ID, and funding amount.
    struct Funding {
        address funder;
        uint256 campaignId;
        uint256 amount;
    }
    
//Declares dynamic arrays to store instances of the Campaign and Funding structs. The public keyword generates a getter function for these arrays.
    Campaign[] public campaigns;
    Funding[] public fundings;
    
//Declares two events: CampaignCreated for logging campaign creation events and ProjectFunded for logging funding events. Events are used to log information and can be observed by external applications.
    event CampaignCreated(uint256 indexed campaignId, address indexed creator, string cause);
    event ProjectFunded(uint256 indexed fundingId, uint256 indexed campaignId, address indexed funder, uint256 amount);
    
//Defines a modifier onlyOwner that restricts the execution of certain functions to be accessible only by the contract owner.
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

//Defines a modifier campaignExists that ensures the given campaign ID is valid and refers to an active campaign.

    modifier campaignExists(uint256 _campaignId) {
        require(_campaignId < campaigns.length && campaigns[_campaignId].isActive, "Campaign does not exist or is not active");
        _;
    }

//Constructor function that runs once when the contract is deployed, setting the owner variable to the address that deploys the contract.

    constructor() {
        owner = msg.sender;
    }

//Function createCampaign allows the owner to create a new campaign with specified details. The onlyOwner modifier ensures that only the owner can call this function.

    function createCampaign(
        string memory _cause,
        string memory _futurePlans,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _goalAmount
    ) external onlyOwner {
         //Checks if the campaign start date is before the end date.
        require(_startDate < _endDate, "Invalid campaign dates");

        //Creates a new Campaign struct with the provided details and initializes the totalFunds to 0 and isActive to true.
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

//Function fundProject allows users to fund a specific campaign. The campaignExists modifier ensures the specified campaign is valid and active.

    function fundProject(uint256 _campaignId) external payable campaignExists(_campaignId) {
    //Gets a reference to the specified campaign from the campaigns array.
        Campaign storage campaign = campaigns[_campaignId];
        //Checks if the funding amount is greater than 0.
        require(msg.value > 0, "Invalid fund amount");
        //Checks if the campaign has not ended based on the current timestamp.
        require(block.timestamp <= campaign.endDate, "Campaign has ended");
        //Checks if the total funds after the new funding do not exceed the campaign's goal amount.
        require(campaign.totalFunds + msg.value <= campaign.goalAmount, "Goal amount reached");

//Creates a new Funding struct with the funder's address, campaign ID, and funding amount, then adds it to the fundings array to keep track of individual fundings.
        Funding memory newFunding = Funding({
            funder: msg.sender,
            campaignId: _campaignId,
            amount: msg.value
        });
        fundings.push(newFunding);
        
        campaign.totalFunds += msg.value;
        emit ProjectFunded(fundings.length - 1, _campaignId, msg.sender, msg.value);
    }

//Updates the total funds of the campaign and emits a ProjectFunded event to log the funding.
//Function getAvailableProjects allows users to view the available active campaigns.
    function getAvailableProjects() external view returns (Campaign[] memory) {
        uint256 activeCampaignsCount = 0;
        for (uint256 i = 0; i < campaigns.length; i++) {
            if (campaigns[i].isActive && block.timestamp <= campaigns[i].endDate) {
                activeCampaignsCount++;
            }
        }
//Iterates through the campaigns array to count the number of active campaigns.
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
//Creates a new array activeCampaigns with a size equal to the number of active campaigns and populates it with active campaigns and Returns the array of active campaigns to the caller.
```

The Funding Platform smart contract allows users to create campaigns, fund projects, and view active campaigns. It is designed to facilitate crowdfunding for various causes and projects on the Ethereum blockchain.

Smart Contract Overview
Campaign Struct
creator: Address of the campaign creator.
cause: Description of the campaign's cause.
futurePlans: Description of the campaign's future plans.
startDate: Timestamp indicating the campaign start date.
endDate: Timestamp indicating the campaign end date.
goalAmount: Funding goal for the campaign.
totalFunds: Total funds raised for the campaign.
funders: Mapping of funders' addresses to their contributed amounts.
Functions
createCampaign
Description: Allows the contract owner to create a new campaign.
# Parameters:
cause: Description of the campaign's cause.
futurePlans: Description of the campaign's future plans.
startDate: Timestamp indicating the campaign start date.
endDate: Timestamp indicating the campaign end date.
goalAmount: Funding goal for the campaign.
Usage: Only the contract owner can create new campaigns using this function.
fundProject
Description: Allows users to fund a specific campaign.
Parameters:
campaignId: Index of the campaign in the campaigns array.
Usage: Users can fund a campaign by specifying the campaign ID and sending Ether along with the transaction.
getAvailableProjects
Description: Allows users to view active campaigns.
Usage: Users can call this function to retrieve a list of active campaigns (campaigns within their start and end dates).
# How to Use
Deploy the Contract:

Deploy the Funding Platform contract on a compatible Ethereum network (Remix IDE, Ethereum Mainnet, Ropsten Testnet, etc.).
Creating a Campaign:

After deploying the contract, use the createCampaign function to create new campaigns by providing the necessary details (cause, future plans, start date, end date, goal amount). Only the contract owner can create campaigns.
Funding a Campaign:

Users can fund a specific campaign by calling the fundProject function with the desired campaignId and sending Ether along with the transaction. Each user can fund a campaign only once.
Viewing Active Campaigns:

Users can call the getAvailableProjects function to retrieve a list of active campaigns. This function returns an array of active campaigns that are within their specified start and end dates.
# Events
CampaignCreated(uint256 indexed campaignId, address indexed creator, string cause): Emitted when a new campaign is created.
ProjectFunded(uint256 indexed campaignId, address indexed funder, uint256 amount): Emitted when a campaign is funded by a user.
# Links :-

Deployed Address Sepolia Etherscan Link : https://sepolia.etherscan.io/tx/0x5c53c46fe7785f69698df9d8b3f03277b63e2cacbc3eda409133db655c15a440

Campaign Creation Link : https://sepolia.etherscan.io/tx/0xacf5fc216d6c0ce0a49d15db12d12e26ee714eec904174ebb13ddcff035408ea

****************************************************************************************************************************
