package com.demo;

public class UserInfo {
    private String createAccountTime;
    private String accountId;
    private UserId[] userIds;
    public String getAccountId() {
        return accountId;
    }
    public String getCreateAccountTime() {
        return createAccountTime;
    }
    public UserId[] getUserIds() {
        return userIds;
    }
    public void setAccountId(String accountId) {
        this.accountId = accountId;
    }
    public void setCreateAccountTime(String createAccountTime) {
        this.createAccountTime = createAccountTime;
    }
    public void setUserIds(UserId[] userIds) {
        this.userIds = userIds;
    }
}