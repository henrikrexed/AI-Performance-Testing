import React, {useEffect, useRef, useState} from 'react';
import useBaseUrl from '@docusaurus/useBaseUrl';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import styles from './styles.module.css';

// DemoClip — the embed harness for the KnightLoad demo recordings.
//
// One component for both surfaces: the landing hero (the loop clip) and the
// inline docs clips (the utility clip). It is deliberately defensive:
//
//   * Primary source is a looping, muted WebM; a GIF is the fallback for
//     browsers that can't play the WebM, plus a <noscript> GIF for no-JS.
//   * A poster still is shown before playback (and is all that paints on the
//     server / first frame), so there is never a blank box.
//   * `prefers-reduced-motion` is respected: we never autoplay for those
//     users — they get the poster with real <video controls> to opt in.
//   * Nothing autoplays until it scrolls into view, and `preload="none"`
//     keeps the WebM off the critical path (payload / Lighthouse budget).
//
// Until the converted demo assets land, `siteConfig.customFields.demoAssetsReady`
// is false and we render a branded placeholder instead of a broken <video>.
// Flipping that flag to true (after dropping the files into static/demo/)
// activates every embed at once.
//
// Expected files per clip `name` (see ASSETS.md in this folder for the spec):
//   static/demo/<name>.webm         primary looping source
//   static/demo/<name>.gif          fallback animation
//   static/demo/<name>.poster.png   still frame / poster
export default function DemoClip({
  name,
  caption,
  priority = false,
  aspect = '16 / 9',
  maxWidth = priority ? 880 : 720,
}) {
  const {siteConfig} = useDocusaurusContext();
  const ready = Boolean(siteConfig.customFields?.demoAssetsReady);

  const webm = useBaseUrl(`/demo/${name}.webm`);
  const gif = useBaseUrl(`/demo/${name}.gif`);
  const poster = useBaseUrl(`/demo/${name}.poster.png`);

  const containerRef = useRef(null);
  const videoRef = useRef(null);
  const [reducedMotion, setReducedMotion] = useState(true); // SSR-safe default
  const [inView, setInView] = useState(priority);

  // Resolve the user's motion preference on the client only.
  useEffect(() => {
    if (typeof window === 'undefined' || !window.matchMedia) return undefined;
    const mq = window.matchMedia('(prefers-reduced-motion: reduce)');
    const update = () => setReducedMotion(mq.matches);
    update();
    mq.addEventListener?.('change', update);
    return () => mq.removeEventListener?.('change', update);
  }, []);

  // Lazy activation: only start loading/playing once scrolled into view.
  useEffect(() => {
    if (priority || inView) return undefined;
    const el = containerRef.current;
    if (!el || typeof IntersectionObserver === 'undefined') {
      setInView(true);
      return undefined;
    }
    const obs = new IntersectionObserver(
      (entries) => {
        if (entries.some((e) => e.isIntersecting)) {
          setInView(true);
          obs.disconnect();
        }
      },
      {rootMargin: '200px'},
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, [priority, inView]);

  const figureStyle = {'--demo-aspect': aspect, '--demo-max-width': `${maxWidth}px`};

  // Placeholder while the real assets haven't shipped yet.
  if (!ready) {
    return (
      <figure
        className={`${styles.clip} ${styles.placeholder}`}
        style={figureStyle}
        data-demo={name}>
        <div className={styles.placeholderInner}>
          <span className={styles.playGlyph} aria-hidden="true">
            ▶
          </span>
          <span className={styles.placeholderLabel}>Demo clip — in production</span>
        </div>
        {caption ? <figcaption className={styles.caption}>{caption}</figcaption> : null}
      </figure>
    );
  }

  const autoplay = inView && !reducedMotion;

  return (
    <figure className={styles.clip} style={figureStyle} data-demo={name} ref={containerRef}>
      <video
        ref={videoRef}
        className={styles.video}
        poster={poster}
        muted
        playsInline
        loop={!reducedMotion}
        autoPlay={autoplay}
        controls={reducedMotion}
        preload={priority ? 'metadata' : 'none'}
        aria-label={caption || `${name} demo clip`}>
        {inView ? <source src={webm} type="video/webm" /> : null}
        {/* Fallback for browsers that can't play the WebM at all. */}
        <img src={gif} alt={caption || `${name} demo (animated)`} loading="lazy" />
      </video>
      <noscript>
        {/* No-JS fallback: the GIF animates on its own. */}
        <img src={gif} alt={caption || `${name} demo (animated)`} />
      </noscript>
      {caption ? <figcaption className={styles.caption}>{caption}</figcaption> : null}
    </figure>
  );
}
