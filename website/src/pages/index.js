import React from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import Mermaid from '@theme/Mermaid';
import styles from './index.module.css';

// Landing-page sections. The loop diagram mirrors docs/how-it-works and the
// project methodology. Brand tokens come from src/css/custom.css.

const LOOP = `flowchart LR
    SCOPE -->|G0| VALIDATE -->|"V1 — human gate"| SYNTHESIZE -->|V2a| EXECUTE -->|V2b| ANALYZE
    ANALYZE -->|"V3 — iterate (≤3x) or escalate"| SCOPE
    classDef gate fill:#16213e,stroke:#2ee6d6,color:#e7ebf0;
    class VALIDATE gate;`;

const DIFFERENTIATORS = [
  {
    title: 'Realism is measured, not guessed.',
    body: 'Journeys, arrival rates, and think-times are derived from your own telemetry — spans, access logs, RUM sessions, and OTel session.id. Nothing is assumed where a number can be extracted.',
  },
  {
    title: 'A human gate is mandatory.',
    body: 'No test runs against any environment until a person reads the proposal and approves the workload model (Gate V1). Approval is bound to the exact model revision; edit the model and the approval is void.',
  },
  {
    title: 'Tests are code you can read.',
    body: 'Every generated test is committed, diffable, and reviewable. Regeneration is deterministic given the same model and seed — no black-box recorder, no artifact you can’t inspect.',
  },
  {
    title: 'Synthetic traffic stays identifiable.',
    body: 'Every generated request carries synthetic=true baggage, promoted to a queryable attribute. Your test traffic and your real traffic never blur — even when they share an environment.',
  },
];

const EXPORTERS = [
  {name: 'k6', note: 'The native fit — open & closed arrival, Zipf payload pools.'},
  {name: 'JMeter', note: 'Concurrency Thread Group + Throughput Shaping Timer, CSV data sets.'},
  {name: 'Gatling', note: 'A single Scala Simulation with JSON feeders.'},
  {name: 'Locust', note: 'locustfile.py with LoadTestShape pacing and shared feeders.'},
];

function Hero() {
  return (
    <header className={styles.hero}>
      <div className="container">
        <p className={styles.eyebrow}>Observability-driven load testing</p>
        <h1 className={styles.heroTitle}>
          Your telemetry already knows what your real workload looks like.
        </h1>
        <p className={styles.heroSubhead}>
          Extract it. Have a human approve it. Replay it faithfully.
        </p>
        <p className={styles.heroSupport}>
          <span className="kl-wordmark">
            <span className="kl-knight">Knight</span>
            <span className="kl-load">load</span>
          </span>{' '}
          turns the traces, logs, and sessions you already collect into a realistic load
          test — one you can read, diff, and trust. Stop hand-writing scenarios that guess
          at how users behave. Load from reality.
        </p>
        <div className={styles.heroButtons}>
          <Link className="button button--primary button--lg" to="/docs/get-started">
            Get started
          </Link>
          <Link className="button button--secondary button--lg" to="/docs/how-it-works">
            Read the methodology
          </Link>
        </div>
      </div>
    </header>
  );
}

function ThesisBand() {
  return (
    <section className={styles.thesis}>
      <div className="container">
        <h2>Most load tests are educated guesses.</h2>
        <p>
          Someone writes a script: a few endpoints, a round number of virtual users, a flat
          ramp. It passes. Production still falls over — because the script never looked
          like the real thing. The journeys were invented, the pacing was a guess, the mix
          was a hunch.
        </p>
        <p>
          KnightLoad starts from the opposite end. The workload you want to replay has
          already happened, and your observability backend recorded it: which request chains
          are common, how they split across user types, how fast traffic actually arrives,
          how long real users pause between steps. KnightLoad extracts those facts into a
          workload model, a human signs off on it, and only then does it become a running
          test.
        </p>
        <p className={styles.pullQuote}>You don’t describe the load. Your telemetry does.</p>
      </div>
    </section>
  );
}

function LoopBand() {
  return (
    <section className={styles.loopBand}>
      <div className="container">
        <h2>One loop, five stages, a gate on every hand-off.</h2>
        <div className={styles.loopDiagram}>
          <Mermaid value={LOOP} />
        </div>
        <p className={styles.loopNote}>
          SCOPE extracts the model, a human approves it at the <strong>V1</strong> gate, and
          only then does it become a running, analyzable test.
        </p>
      </div>
    </section>
  );
}

function Differentiators() {
  return (
    <section className={styles.differentiators}>
      <div className="container">
        <h2 className={styles.bandHeading}>Why it’s different</h2>
        <div className={styles.cardGrid}>
          {DIFFERENTIATORS.map((d) => (
            <div key={d.title} className={styles.card}>
              <h3>{d.title}</h3>
              <p>{d.body}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function ExportersBand() {
  return (
    <section className={styles.exporters}>
      <div className="container">
        <h2 className={styles.bandHeading}>One approved model. Four load tools.</h2>
        <p className={styles.bandLead}>
          KnightLoad separates <em>what to replay</em> from <em>what runs it</em>. Once your
          workload model is approved, render it to the load tool your team already uses.
          Every renderer reads the same model as its only contract, and each one honestly
          declares where it approximates.
        </p>
        <div className={styles.exporterRow}>
          {EXPORTERS.map((e) => (
            <div key={e.name} className={styles.exporterChip}>
              <span className={styles.exporterName}>{e.name}</span>
              <span className={styles.exporterNote}>{e.note}</span>
            </div>
          ))}
        </div>
        <div className={styles.bandCta}>
          <Link className="button button--primary" to="/docs/exporters">
            Compare the exporters
          </Link>
        </div>
      </div>
    </section>
  );
}

function ClosingCta() {
  return (
    <section className={styles.closing}>
      <div className="container">
        <h2>Ready to load from reality?</h2>
        <p>
          Clone the repo and run the first half of the loop on a bundled example in about
          ten minutes — no backend, no tokens. When you’re ready, point it at your own
          Dynatrace trial and run the full loop end to end.
        </p>
        <div className={styles.heroButtons}>
          <Link className="button button--primary button--lg" to="/docs/get-started">
            Get started
          </Link>
          <Link
            className="button button--secondary button--lg"
            href="https://github.com/henrikrexed/AI-Performance-Testing">
            View on GitHub
          </Link>
        </div>
      </div>
    </section>
  );
}

export default function Home() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={`${siteConfig.title} — ${siteConfig.tagline}`}
      description="KnightLoad turns your observability data into realistic, human-approved load tests — with a mandatory human gate and traffic you can always tell apart.">
      <Hero />
      <main>
        <ThesisBand />
        <LoopBand />
        <Differentiators />
        <ExportersBand />
        <ClosingCta />
      </main>
    </Layout>
  );
}
