from flask import Flask, request, jsonify
import joblib
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer

app = Flask(__name__)

# Load the trained model and vectorizer
model = joblib.load('xgb_model.pkl')  # Path to your saved XGBoost model
vectorizer = joblib.load('vectorizer.pkl')  # Path to your saved CountVectorizer or TfidfVectorizer

# Define the label mapping
label_mapping = {
    0: 'Anxiety',
    1: 'Normal',
    2: 'Depression',
    3: 'Suicidal',
    4: 'Stress',
    5: 'Bipolar',
    6: 'Personality disorder'
}

def predict_new_text(text, c_vectorizer, model):
    """
    Predicts the category of a given text using the trained vectorizer and model.
    """
    # Transform the input text using the vectorizer
    text_vector = c_vectorizer.transform([text])

    # Predict the category index
    predicted_index = model.predict(text_vector)[0]

    # Map the predicted index to the category label
    predicted_label = label_mapping[predicted_index]

    return {predicted_label: predicted_index}

@app.route('/predict', methods=['POST'])
def predict():
    try:
        # Get the input text from the request
        data = request.json
        text = data['text']

        # Get prediction from the model
        prediction = predict_new_text(text, vectorizer, model)

        # Return the prediction result
        return jsonify(prediction)
    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    app.run(debug=True)
