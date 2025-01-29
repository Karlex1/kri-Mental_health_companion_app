from flask import Flask, request, jsonify
import joblib
from flask_cors import CORS

CORS(app)

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

# Therapist data from the provided JSON
therapists = [
    {"id":"1","name": "Dr. Sneha Sharma", "specialization": "Psychotherapist", "experience_years": 12, "consultation_fee": 1500, "clinic_location": "Delhi", "rating_percentage": 100, "reviews_count": 29},
    {"id":"2","name": "Ms. Harvinder Kaur", "specialization": "Psychotherapist", "experience_years": 23, "consultation_fee": 2999, "clinic_location": "Delhi", "rating_percentage": 100, "reviews_count": 167},
    {"id":"3","name": "Ms. Tejasvini Sinha", "specialization": "Neuropsychologist", "experience_years": 9, "consultation_fee": 1000, "clinic_location": "Vasant Vihar, Delhi", "rating_percentage": 98, "reviews_count": 183},
    {"id":"4","name": "Dr. D.Senthil Kumar", "specialization": "Counselling Psychologist", "experience_years": 24, "consultation_fee": 600, "clinic_location": "Chennai", "rating_percentage": 94, "reviews_count": 145},
    {"id":"5","name": "Dr. Anju Soni", "specialization": "Counselling Psychologist", "experience_years": 11, "consultation_fee": 1400, "clinic_location": "Chennai", "rating_percentage": 100, "reviews_count": 83},
    {"id":"6","name": "Ms. Rupal Jain", "specialization": "Psychologist", "experience_years": 11, "consultation_fee": 1000, "clinic_location": "Mumbai", "rating_percentage": 99, "reviews_count": 71},
    {"id":"7","name": "Dr. Harshant Upadhyaya", "specialization": "Psychologist", "experience_years": 19, "consultation_fee": 3000, "clinic_location": "Mumbai", "rating_percentage": 97, "reviews_count": 51},
    {"id":"8","name": "Ms. Rashi Laskari", "specialization": "Psychologist", "experience_years": 15, "consultation_fee": 1800, "clinic_location": "Mumbai", "rating_percentage": 98, "reviews_count": 90},
    {"id":"9","name": "Ms. Mithila Desai", "specialization": "Psychologist", "experience_years": 36, "consultation_fee": 2850, "clinic_location": "Mumbai", "rating_percentage": 93, "reviews_count": 95},
    {"id":"10","name": "Dr. Keerti Sachdeva", "specialization": "Psychologist", "experience_years": 39, "consultation_fee": 2000, "clinic_location": "Mumbai", "rating_percentage": 87, "reviews_count": 35},
    {"id":"12","name": "Ms. Riddhi Sagar", "specialization": "Psychologist", "experience_years": 11, "consultation_fee": 2000, "clinic_location": "Mumbai", "rating_percentage": 98, "reviews_count": 57},
    {"id":"13","name": "Dr. Naazneen Ladak", "specialization": "Psychologist", "experience_years": 18, "consultation_fee": 2000, "clinic_location": "Mumbai", "rating_percentage": 91, "reviews_count": 178},
    {"id":"14","name": "Dr. Dharmendra Solanki", "specialization": "Psychologist", "experience_years": 21, "consultation_fee": 2500, "clinic_location": "Mumbai", "rating_percentage": 97, "reviews_count": 69},
    {"id":"15","name": "Ms. Mansi D Chheda", "specialization": "Psychologist", "experience_years": 11, "consultation_fee": 3000, "clinic_location": "Mumbai", "rating_percentage": 99, "reviews_count": 166},
    {"id":"16","name": "Ms. Purvi Palvia", "specialization": "Psychologist", "experience_years": 7, "consultation_fee": 2100, "clinic_location": "Mumbai", "rating_percentage": 95, "reviews_count": 40},
    {"id":"17","name": "Ms. Hema Sampath", "specialization": "Counselling Psychologist", "experience_years": 18, "consultation_fee": 2000, "clinic_location": "Bangalore", "rating_percentage": 87, "reviews_count": 178},
    {"id":"18","name": "Ms. Monisha Preetha", "specialization": "Counselling Psychologist", "experience_years": 3, "consultation_fee": 1300, "clinic_location": "Bangalore", "rating_percentage": 100, "reviews_count": 35},
    {"id":"19","name": "Dr. Prashanthi K.", "specialization": "Counselling Psychologist", "experience_years": 16, "consultation_fee": 1499, "clinic_location": "Bangalore", "rating_percentage": 95, "reviews_count": 47},
    {"id":"20","name": "Mr. Chetan Manjalekar", "specialization": "Counselling Psychologist", "experience_years": 8, "consultation_fee": 1200, "clinic_location": "Bangalore", "rating_percentage": 96, "reviews_count": 42},
    {"id":"21","name": "Ms. Navya Sree Nambiar", "specialization": "Counselling Psychologist", "experience_years": 7, "consultation_fee": 1500, "clinic_location": "Bangalore", "rating_percentage": 96, "reviews_count": 13},
    {"id":"22","name": "Dr. Shabana M S (PhD)", "specialization": "Counselling Psychologist", "experience_years": 15, "consultation_fee": 2500, "clinic_location": "Bangalore", "rating_percentage": 100, "reviews_count": 2},
    {"id":"23","name": "Ms. Ayana Sunil Variar", "specialization": "Counselling Psychologist", "experience_years": 8, "consultation_fee": 1500, "clinic_location": "Bangalore", "rating_percentage": 100, "reviews_count": 11},
    {"id":"24","name": "Ms. Shruti Chaubey", "specialization": "Counselling Psychologist", "experience_years": 9, "consultation_fee": 1900, "clinic_location": "Bangalore", "rating_percentage": 100, "reviews_count": 38},
    {"id":"25","name": "Dr. Chaya", "specialization": "Counselling Psychologist", "experience_years": 19, "consultation_fee": 1500, "clinic_location": "Bangalore", "rating_percentage": 97, "reviews_count": 188},
    {"id":"26","name": "Ms. Sheetal N Chauhan", "specialization": "Counselling Psychologist", "experience_years": 8, "consultation_fee": 1500, "clinic_location": "Bangalore", "rating_percentage": 92, "reviews_count": 17},
    {"id":"27","name": "Dr. Priya G", "specialization": "Psychologist", "experience_years": 12, "consultation_fee": 2500, "clinic_location": "Bangalore", "rating_percentage": 95, "reviews_count": 60},
    {"id":"28","name": "Dr. Sumit Soni", "specialization": "Psychotherapist", "experience_years": 9, "consultation_fee": 1200, "clinic_location": "Kolkata", "rating_percentage": 90, "reviews_count": 53},
    {"id":"29","name": "Ms. Priya Verma", "specialization": "Psychotherapist", "experience_years": 5, "consultation_fee": 1500, "clinic_location": "Delhi", "rating_percentage": 88, "reviews_count": 24},
    {"id":"30","name": "Dr. Ananya Banerjee", "specialization": "Counseling Psychologist", "experience_years": 8, "consultation_fee": 2200, "clinic_location": "Kolkata", "rating_percentage": 94, "reviews_count": 65},
    {"id":"31","name": "Dr. Vaibhav Kapoor", "specialization": "Psychiatrist", "experience_years": 15, "consultation_fee": 1800, "clinic_location": "Delhi", "rating_percentage": 96, "reviews_count": 71},
    {"id":"32","name": "Ms. Rashmi Tripathi", "specialization": "Counselling Psychologist", "experience_years": 7, "consultation_fee": 2500, "clinic_location": "Gurugram", "rating_percentage": 93, "reviews_count": 33}
]

@app.route('/therapists', methods=['GET'])
def get_therapists():
    try:
        # Get query parameters for pagination
        page = int(request.args.get('page', 1))  # Default to page 1
        per_page = int(request.args.get('per_page', 10))  # Default 10 therapists per page

        # Validate inputs
        if page < 1 or per_page < 1:
            return jsonify({'error': 'Page and per_page must be positive integers'}), 400

        # Calculate start and end indices
        start = (page - 1) * per_page
        end = start + per_page

        # Slice the therapists list for the current page
        paginated_therapists = therapists[start:end]

        # Return the paginated results with metadata
        return jsonify({
            'therapists': paginated_therapists,
            'page': page,
            'per_page': per_page,
            'total': len(therapists),
            'total_pages': (len(therapists) + per_page - 1) // per_page  # Round up
        })
    except ValueError:
        return jsonify({'error': 'Invalid query parameters'}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500




if __name__ == '__main__':
    app.run(debug=True)
