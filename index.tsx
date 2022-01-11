import React, { Component } from 'react';
import { render } from 'react-dom';
import Hello from './Hello';
import './style.css';

interface AppProps { }
interface AppState {
  name: string;
}

class App extends Component<AppProps, AppState> {
  constructor(props) {
    super(props);
    this.state = {
      name: 'Fabio'
    };
  }

  render() {
    return (
      <div>
        <Hello name={this.state.name} />
        <p>
          prova01
        </p>
      </div>
    );
  }
}

render(<App />, document.getElementById('root'));
