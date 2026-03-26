# Base controller for all onboarding-layout pages (login, registration, setup steps).
# Subclassed directly by SessionsController, RegistrationsController.
# Setup-step controllers inherit from Onboarding::StepController which adds a setup-incomplete guard.
class OnboardingController < ApplicationController
  layout "onboarding"
end
