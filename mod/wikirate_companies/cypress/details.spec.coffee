describe "expanding details on company pages", ->
  specify "WikiRating", ->
    cy.visit "Death Star"

    # use filter to find darkness rating
    cy.get("._filters-button a").click()
    cy.get(".offcanvas").within () ->
      cy.contains("Metric Name").click()
      cy.get("[name='filter[metric_name]']").type("darkness{enter}")
    cy.get(".offcanvas-header .btn-close").click()

    # filter works
    cy.root().should "not.contain", "deadliness"

    # expand details
    cy.contains("darkness rating").click()

    cy.contains "deadliness"
    cy.contains "disturbance"

    # expand details of first score
    cy.get("tbody tr:first-child .range-value").contains("10").click()
    cy.contains "Scored Metric"
    cy.get("._modal-slot").should "not.contain", "disturbance"
    cy.get("._modal-slot").should "not.contain", "Sources"

    # expand details of raw value
    cy.get("._modal-slot").within () ->
      cy.contains("100").click()
    cy.get("._modal-slot").should "not.contain", "Scored Metric"
    cy.contains "Sources"
    cy.contains "thereaderwiki.com"

    # close raw value
    cy.wait 400 # let modal transition finish
    cy.get("._modal-slot ._close-modal").click()
    cy.contains "Scored Metric"
    cy.get("._modal-slot").should "not.contain", "disturbance"
    cy.get("._modal-slot").should "not.contain", "Sources"

    # close score
    cy.wait 400 # let modal transition finish
    cy.get("._modal-slot ._close-modal").click()
    cy.get("._modal-slot").should "not.contain", "Scored Metric"
    cy.contains "deadliness"
    cy.contains "disturbance"
