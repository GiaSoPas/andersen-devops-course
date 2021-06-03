from flask import Flask, request
app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def main():
    if request.method == 'POST':
        request_data = request.get_json(force=True)

        animal = None
        sound = None
        count = None

        if request_data:
            if 'animal' in request_data:
                animal = request_data['animal']
                if animal == 'cow':
                    animal = '🐮'
                if animal == 'elephant':
                    animal = '🐘'

            if 'sound' in request_data:
                sound = request_data['sound']

            if 'count' in request_data:
                count = request_data['count']

            if count is not None:
                out = '{} says {}\n'.format(animal, sound)*count + \
                'Made with ❤️  by {}\n'.format('Gizar Zigangirov')
            else:
                out = '{} says {}\n'.format(animal, sound) + \
                'Made with ❤️  by {}\n'.format('Gizar Zigangirov')

        return out
    else:
        pass

if __name__=="__main__":
    app.run(port=5000)
