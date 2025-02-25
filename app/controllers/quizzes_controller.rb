class QuizzesController < ApplicationController
  require "openai"
  require "dotenv/load"
  before_action :set_quiz, only: [:show, :destroy]

  def index
    @quizzes = Quiz.order(created_at: :desc)
  end

  def show
    @messages = @quiz.messages.order(:created_at)
  end

  def new
    @quiz = Quiz.new
  end

  require "openai"

  def create
    @quiz = Quiz.create(topic: params[:query_topic])

    # Add system message
    @quiz.messages.create(role: "system", content: "You are an AI tutor. Ask the user five questions to assess their proficiency on this topic. Start with an easy question and adjust difficulty based on responses. Provide a score between 0 and 10 at the end.")

    # Add user message
    user_message = @quiz.messages.create(role: "user", content: "Can you assess my proficiency in #{@quiz.topic}?")

    # Generate assistant message via OpenAI API
    assistant_response = generate_ai_response(@quiz)

    # Store assistant message
    @quiz.messages.create(role: "assistant", content: assistant_response)

    redirect_to quiz_path(@quiz)
  end

  def destroy
    @quiz.destroy
    redirect_to quizzes_path
  end

  private

  def set_quiz
    @quiz = Quiz.find(params[:id])
  end

  def quiz_params
    params.require(:quiz).permit(:topic)
  end

  def generate_ai_response(quiz)
    puts ENV["OPENAI_API_KEY"]
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    messages = quiz.messages.order(:created_at).map { |msg| { role: msg.role, content: msg.content } }

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: messages,
        max_tokens: 100
      }
    )

    response.dig("choices", 0, "message", "content") || "I'm ready to start your quiz!"
  end
end
