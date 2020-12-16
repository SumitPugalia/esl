# Esl
## REST API ENDPOINT
**/api/top_stories** 
- return the latest 10 top stories, along with the version

**/api/top_stories?version=xxx&page_number=1&page_size=10**
- return the next 10 top stories, make sure the version is not older than 5 mins else it will throw error. if no version is passed it will use latest data.

## WEBSOCKET ENDPOINT
**/** 
- we can inspect to see the websocket connection and values being updated

## TESTING

- test to see that the state of top_stories changes every 'x' interval of time.
- test our system dnt throw error and don't update the old data when hacker news is down.
- test top_stories server broadcast the data to channel for every update in its state.