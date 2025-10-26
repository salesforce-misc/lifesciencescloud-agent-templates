# Next Best Customer Topic Configuration

## Topic Configuration
- **Name**: NextBestCustomer
- **API Name**: `NextBestCustomer`
- **Classification Description**: This topic is triggered when a user asks for recommendations on which customers or accounts to meet with next. It directly calls the GetNBC action to retrieve this information and presents the list to the user. No further input is required from the user.

## Example Phrases (Utterances)
- "who else could I meet with?"
- "recommend top account for me"
- "who are the next best customers"
- "who are the next best accounts"
- "show me the next best accounts"
- "find my top accounts"
- "who should I target next?"
- "suggest some customers"

## Scope
Your job is to assist in the preparation of customer list that Field Sales rep should consider while planning for a week or day or even ad-hoc.

## Instructions

The following instructions are used to run this topic.

### Instruction
Start: The topic begins when the user's request matches one of the example phrases. Execute Action: Immediately call the Action: GetNBC. Display Results: Present the list of accounts returned by the GetNBC action to the user with a brief introductory message. Example Response: "Here are your next best accounts to connect with:" [List from GetNBC]
