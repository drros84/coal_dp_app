function(input, output, session) {
  
  plots_DP <- reactive({
    if(input$DP_choose == "dp_basis"){
     sim1 <-   simulation_DP_basis(N = input$N,
                           real_capacity_per_year = real_capacity_per_year,
                           mines = ncol(real_capacity_per_year),
                           capacity = input$CPY,
                           total_capacity_of_mine = c(input$num1, input$num2, input$num3,
                                                     input$num4, input$num5, input$num6),
                          extraction_cost_per_tone = input$C,
                          alpha_coking = input$alpha_coking,
                          alpha_thermal = input$alpha_thermal,
                          b_coking = input$b_coking,
                          b_thermal = input$b_thermal,
                          sd_coking = input$sd_coking,
                          sd_thermal = input$sd_thermal,
                          rho = c(input$rho1, input$rho2, input$rho3,
                                  input$rho4, input$rho5, input$rho6))
     }
    if(input$DP_choose == "dp_transport"){
       sim1 <-  simulation_DP_transport(N = input$N,
                          real_capacity_per_year = real_capacity_per_year,
                          mines = ncol(real_capacity_per_year),
                          capacity = input$CPY,
                          total_capacity_of_mine = c(input$num1, input$num2, input$num3,
                                                     input$num4, input$num5, input$num6),
                          extraction_cost_per_tone = input$C,
                          alpha_coking = input$alpha_coking,
                          alpha_thermal = input$alpha_thermal,
                          b_coking = input$b_coking,
                          b_thermal = input$b_thermal,
                          sd_coking = input$sd_coking,
                          sd_thermal = input$sd_thermal,
                          rho = c(input$rho1, input$rho2, input$rho3,
                                  input$rho4, input$rho5, input$rho6),
                          Trans_lim = input$TL,
                          salvage = input$S)
    }
    sim1
  })
  
  output$plot <- renderPlot({
    if(input$Coal_Type == "total_graphs")
      plot1 <- plots_DP()$X_plot
    if(input$Coal_Type == "thermal_graphs")
      plot1 <- plots_DP()$X_thermal_plot
    if(input$Coal_Type == "coking_graphs")
      plot1 <- plots_DP()$X_coking_plot
    plot1
  })
  output$g_k_graph <- renderPlot({
    if(input$Coal_Type == "total_graphs")
      plot2 <- plots_DP()$g_k_plot
    if(input$Coal_Type == "thermal_graphs")
      plot2 <- plots_DP()$X_thermal_g_k_plot
    if(input$Coal_Type == "coking_graphs")
      plot2 <- plots_DP()$X_coking_g_k_plot
    plot2
  })
  # Plot the accumulated reward g
  output$g_graph <- renderPlot({
    if(input$Coal_Type == "total_graphs")
      plot3 <- plots_DP()$g_plot
    if(input$Coal_Type == "thermal_graphs")
      plot3 <- plots_DP()$X_thermal_g_plot
    if(input$Coal_Type == "coking_graphs")
      plot3 <- plots_DP()$X_coking_g_plot
    plot3
  })  
}
