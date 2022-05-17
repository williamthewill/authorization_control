defmodule AuthorizationControlWeb.PatternMessage do
  def call do
    %{}
  end

  def call(param) do
    %{
      notFound: "#{param} not found!",
      missingEmailInfo: "The following stores are missing email info: #{param}.",
      returnedErrorApi: "The #{param} route returned an error when the api was called.",
      responseIsNotValues: "The response from the #{param} route is not the values.",
      jobCalled: "The following job: #{param} has been initialized."
    }
  end
end
