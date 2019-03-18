#Author: your.email@your.domain.com
#Keywords Summary :
#Feature: List of scenarios.
#Scenario: Business rule through list of steps with arguments.
#Given: Some precondition step
#When: Some key actions
#Then: To observe outcomes or validation
#And,But: To enumerate more Given,When,Then steps
#Scenario Outline: List of steps for data-driven as an Examples and <placeholder>
#Examples: Container for s table
#Background: List of steps run before each of the scenarios
#""" (Doc Strings)
#| (Data Tables)
#@ (Tags/Labels):To group Scenarios
#<> (placeholder)
#""
## (Comments)
#Sample Feature Definition Template
@US14
Feature: US14 - As Consular Personal I want a centralized Web portal, So that I can include Visa history based on applicant search options

  @US14Positive
  Scenario: Search Person using First and Names
    Given Consular is searching for Person
    And <First> and <Names> are entered in First and Names search fields
    And CDD check box is checked
    And clicks on request
    Then the visa history records are displayed in the results table

  @US14Positive
  Scenario: Search Person using DOB
    Given Consular is searching for Person
    When <DOB> is entered in DOB search field
    And CDD check box is checked
    And clicks on request
    Then the visa history records are displayed in the results table

  @US14Negative
  Scenario: Search Person using invalid ANumber
    Given Consular is searching for Person
    When an invalid <ANumber> is entered in ANumber search field
    Then the request button is disabled
    And error message is displayed to the user

  @US14Negative
  Scenario: Search Person using invalid First and Names
    Given Consular is searching for Person
    When an invalid <First> and <Names> are entered in First and Names search fields
    Then the request button is disabled
    And error message is displayed to the user

  @US14Negative
  Scenario: Search Person using invalid DOB
    Given Consular is searching for Person
    When an invalid <DOB> is entered in DOB search field
    Then the request button is disables
    And error message is displayed to the user

  @US14Negative
  Scenario: Search Person with CCD is not checked
    Given Consular is searching for Person
    When the CDD box is NOT checked
    Then No visa history information should be provided

  @US14Negative
  Scenario: Search Person with No box being not checked
    Given Consular is searching for Person
    When the NO box is NOT checked
    Then the request button should be disable
