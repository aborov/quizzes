class MessagesController < ApplicationController
  before_action :set_quiz

  def create
    @quiz = Quiz.find(params[:quiz_id])
    @message = @quiz.messages.create(message_params)

    assistant_response = generate_ai_response(@quiz)

    @quiz.messages.create(role: "assistant", content: assistant_response)

    redirect_to quiz_path(@quiz)
  end

  private

  def set_quiz
    @quiz = Quiz.find(params[:quiz_id])
  end

  def message_params
    params.require(:message).permit(:role, :content)
  end

  def generate_ai_response(quiz)
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    messages = quiz.messages.order(:created_at).map { |msg| { role: msg.role, content: msg.content } }

    begin
      response = client.chat(
        parameters: {
          model: "gpt-4o-mini",
          messages: messages,
          max_tokens: 100
        }
      )

      response.dig("choices", 0, "message", "content") || "I'm ready to start your quiz!"
    rescue Faraday::ResourceNotFound => e
      Rails.logger.error("OpenAI API Resource Not Found: #{e.message}")
      return "Error: OpenAI API resource not found."
    rescue OpenAI::Error => e
      Rails.logger.error("OpenAI API Error: #{e.message}")
      return "Error: OpenAI API request failed."
    rescue StandardError => e
      Rails.logger.error("An unexpected error occurred: #{e.message}")
      return "An unexpected error occurred."
    end
  end
end
