# github-repositories

## Github Repositories Feature

### Story: Customer requests to see trending github repositories

### Narrative #1

```
As an online customer
I want the app to automatically load trending github repositories
So I can see the latest repositories
```

#### Scenarios (Acceptance criteria)

```
Given the customer has connectivity
When the customer requests to see github repositories
Then the app should display the latest trending github repositories
```

### Narrative #2

```
As an offline customer 
I want the app to show the latest version of trending github repositories
So I can browse through the list of repositories
```

#### Scenarios (Acceptance criteria)

```
Given the customer doesn't have connectivity
  And there's a cached version of the repositories
When the customer requests to see the repositories
Then the app should display the latest repositories saved
```

```
Given the customer doesn't have connectivity
 And the cache is empty
When the customer requests to see the repositories
Then the app should display an error message
```
